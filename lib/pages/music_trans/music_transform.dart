import 'dart:convert' as convert;
import 'dart:io';

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:concurrent_queue/concurrent_queue.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/FtpCmd.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/circle_widget.dart';
import 'package:lovelivemusicplayer/widgets/horizontal_line.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/io.dart';

class MusicTransform extends StatefulWidget {
  const MusicTransform({Key? key}) : super(key: key);

  @override
  State<MusicTransform> createState() => _MusicTransformState();
}

class _MusicTransformState extends State<MusicTransform> {
  IOWebSocketChannel? channel;
  final queue = ConcurrentQueue(concurrency: 1);

  var isConnected = false;

  // 当前传输的歌曲
  DownloadMusic? currentMusic;

  // 待下载的歌曲列表
  final musicList = <DownloadMusic>[];
  String port = "10000";

  // 下载文件的进度
  int currentProgress = 0;
  bool isRunning = false;

  // 可取消的网络请求token
  CancelToken? cancelToken;

  // 当前传输的索引
  int index = 0;

  // 是否准备开始传输任务
  bool isStartDownload = false;

  // 是否是无传输模式
  bool isNoTrans = false;

  String? ipAddress;

  // banner控制器，无作用，但是必须加，代码控制时也需要这个
  final controller = TransformerPageController();

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    AppUtils.uploadEvent("MusicTransform");
  }

  List<Map<String, String>> genFileList(DownloadMusic music) {
    final picUrl = "http://$ipAddress:$port/${music.baseUrl}${music.coverPath}";
    String musicUrl =
        "http://$ipAddress:$port/${music.baseUrl}${music.musicPath}";

    final picDest = SDUtils.path + music.baseUrl + music.coverPath;
    String musicDest = SDUtils.path + music.baseUrl + music.musicPath;
    if (Platform.isIOS) {
      musicUrl = musicUrl.replaceAll(".flac", ".wav");
      musicDest = musicDest.replaceAll(".flac", ".wav");
    }

    final List<Map<String, String>> array = [];

    array.add({"url": picUrl, "dest": picDest});
    array.add({"url": musicUrl, "dest": musicDest});

    final tempList = musicDest.split(Platform.pathSeparator);
    var destDir = "";
    for (var i = 0; i < tempList.length - 1; i++) {
      destDir += tempList[i] + Platform.pathSeparator;
    }
    SDUtils.makeDir(destDir);
    if (!isRunning) {
      return [];
    }

    return array;
  }

  pushQueue(DownloadMusic music, String url, String dest, bool isMusic,
      bool isLast) async {
    await queue.add(() async {
      try {
        cancelToken = CancelToken();
        await Network.download(url, dest, (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            if (isMusic) {
              final p = double.parse(progress).truncate();
              if (currentProgress != p) {
                currentProgress = p;
                currentMusic = music;
                if (progress == "100") {
                  final message = ftpCmdToJson(
                      FtpCmd(cmd: "download success", body: music.musicUId));
                  channel?.sink.add(message);
                } else {
                  if (isRunning) {
                    final message = ftpCmdToJson(
                        FtpCmd(cmd: "downloading", body: music.musicUId));
                    channel?.sink.add(message);
                  }
                }
                setState(() {});
              }
            } else if (progress == "100") {
              changeNextTaskView(music);
            }
          }
        }, cancelToken);
        if (isMusic) {
          if (Platform.isIOS && music.musicPath.endsWith(".flac")) {
            music.musicPath = music.musicPath.replaceAll(".flac", ".wav");
          }
          await DBLogic.to.importMusic(music);
        }
      } catch (e) {
        final message =
            ftpCmdToJson(FtpCmd(cmd: "download fail", body: music.musicUId));
        channel?.sink.add(message);
        changeNextTaskView(music);
        setState(() {});
      }
    });
    if (isLast) {
      await queue.onIdle();
      final message = ftpCmdToJson(FtpCmd(cmd: "finish", body: ""));
      channel?.sink.add(message);
      await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
      Get.back();
    }
  }

  changeNextTaskView(DownloadMusic music) {
    for (var i = 0; i < musicList.length; i++) {
      if (musicList[i].musicUId == music.musicUId) {
        if (index < musicList.length) {
          index = i + 1;
          isStartDownload = true;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: isConnected
            ? () async {
                showBackDialog();
                return false;
              }
            : null,
        child: body());
  }

  Widget body() {
    return Scaffold(
        body: Column(
      children: [
        DetailsHeader(
            title: '歌曲快传',
            onBack: () {
              if (isConnected) {
                showBackDialog();
              } else {
                Get.back();
              }
            }),
        Visibility(visible: isConnected, child: renderTransView()),
        Visibility(visible: !isConnected, child: renderNoTransView())
      ],
    ));
  }

  Widget renderTransView() {
    return Column(
      children: [
        SizedBox(height: 35.h),
        drawBody(),
        SizedBox(height: 20.h),
        drawMusicInfo(),
        SizedBox(height: 40.h),
        drawProgressBar()
      ],
    );
  }

  Widget renderNoTransView() {
    return Column(
      children: [
        SizedBox(height: 15.h),
        Visibility(
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            visible: !isConnected,
            child: Center(
                child: SvgPicture.asset(Assets.syncIconDataSync,
                    width: 300.r, height: 300.r))),
        SizedBox(height: 65.h),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(Assets.drawerDrawerSecret,
              width: 15.r, height: 15.r),
          SizedBox(width: 2.r),
          Text("请保持手机和电脑处于同一局域网内", style: TextStyleMs.gray_12)
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: 15.r),
          Text("保持屏幕常亮，并扫描PC端二维码", style: TextStyleMs.gray_12)
        ]),
        SizedBox(height: 90.h),
        Visibility(
            visible: !isConnected,
            child: btnFunc(Assets.syncIconScanQr, "设备配对", () async {
              final ip = await Get.toNamed(Routes.routeScan);
              if (ip != null) {
                ipAddress = ip;
                openWS();
              }
            }))
      ],
    );
  }

  Widget drawMusicInfo() {
    if (currentMusic == null) {
      return SizedBox(height: 60.h);
    } else {
      return SizedBox(
        height: 60.h,
        child: Column(
          children: [
            Text(currentMusic!.musicName,
                style: Get.isDarkMode
                    ? TextStyleMs.white_15
                    : TextStyleMs.black_15,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(currentMusic!.artist,
                style: TextStyleMs.gray_12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }
  }

  Widget drawBody() {
    if (isNoTrans || index <= 0 || musicList.length < index) {
      return Container(
          width: 300.h,
          height: 300.h,
          color: Get.theme.primaryColor,
          child: const Image(image: AssetImage(Assets.logoLogo)));
    } else {
      return SizedBox(
        width: 300.h,
        height: 300.h,
        child: TransformerPageView(
          index: index - 1,
          viewportFraction: 0.8,
          pageController: controller,
          transformer: ScaleAndFadeTransformer(),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final mCoverPath =
                musicList[index].baseUrl + musicList[index].coverPath;
            return showImg(SDUtils.getImgPath(fileName: mCoverPath), 400, 400,
                hasShadow: false, radius: 12);
          },
          itemCount: musicList.length,
        ),
      );
    }
  }

  Widget drawProgressBar() {
    int current = index;
    int total = musicList.length;
    double percent = current / total * 100;
    return Stack(
      children: [
        /// 里圈
        SizedBox(
          width: 190.h,
          height: 190.h,
          child: Center(
            child: CustomPaint(
              size: Size(160.h, 160.h),
              painter: CircleView(
                completePercent: isStartDownload ? percent.roundToDouble() : 0,
                completeColor: ColorMs.colorF940A7,
                lineColors: [ColorMs.colorF940A7],
                completeWidth: 8.w,
                width: 1.w,
                isDividerRound: true,
                lineColor: ColorMs.colorF940A7,
              ),
            ),
          ),
        ),

        /// 外圈
        CustomPaint(
          size: Size(190.h, 190.h),
          painter: CircleView(
            completePercent: 100,
            completeColor: ColorMs.colorF940A7.withAlpha(26),
            lineColors: [],
            completeWidth: 8.w,
          ),
        ),

        /// 中间文字
        drawInnerText(current, total)
      ],
    );
  }

  Widget drawInnerText(int current, int total) {
    if (isStartDownload) {
      return SizedBox(
        width: 190.h,
        height: 190.h,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("$current",
                style: Get.isDarkMode
                    ? TextStyleMs.white_15
                    : TextStyleMs.black_15),
            SizedBox(height: 15.h),
            HorizontalLine(
                dashedHeight: 1.h,
                dashedWidth: 70.w,
                color: ColorMs.colorCCDDF1),
            SizedBox(height: 15.h),
            Text("$total",
                style: Get.isDarkMode
                    ? TextStyleMs.white_15
                    : TextStyleMs.black_15)
          ],
        )),
      );
    } else {
      return SizedBox(
          width: 190.h,
          height: 190.h,
          child: Center(
              child: Text("数据解析中...",
                  style: Get.isDarkMode
                      ? TextStyleMs.white_15
                      : TextStyleMs.black_15)));
    }
  }

  openWS() {
    channel = IOWebSocketChannel.connect(Uri.parse("ws://$ipAddress:4388"));
    channel!.stream.listen((msg) async {
      final ftpCmd = ftpCmdFromJson(msg as String);
      switch (ftpCmd.cmd) {
        case "noTrans":
          isNoTrans = true;
          musicList.addAll(downloadMusicFromJson(ftpCmd.body));
          isStartDownload = true;
          setState(() {});
          Future.forEach<DownloadMusic>(musicList, (music) async {
            if (File(SDUtils.path + music.baseUrl + music.musicPath)
                .existsSync()) {
              currentMusic = music;
              changeNextTaskView(music);
              setState(() {});
              await DBLogic.to.importMusic(music);
            }
          }).then((_) {
            DBLogic.to
                .findAllListByGroup(GlobalLogic.to.currentGroup.value)
                .then((value) => Get.back());
          });
          break;
        case "port":
          port = ftpCmd.body;
          break;
        case "prepare":
          if (ftpCmd.body.contains(" === ")) {
            final array = ftpCmd.body.split(" === ");
            final json = array[0];
            final needTransAll = array[1] == "true" ? true : false;
            final downloadList = downloadMusicFromJson(json);
            final musicIdList = <String>[];
            Future.forEach<DownloadMusic>(downloadList, (music) async {
              if (needTransAll) {
                // 强制传输则添加到预下载列表
                musicIdList.add(music.musicUId);
              } else {
                String filePath =
                    SDUtils.path + music.baseUrl + music.musicPath;
                if (Platform.isIOS) {
                  filePath = filePath.replaceAll(".flac", ".wav");
                }
                if (SDUtils.checkFileExist(filePath)) {
                  // 文件存在则尝试插入
                  await DBLogic.to.importMusic(music);
                } else {
                  // 文件不存在则添加到预下载列表
                  musicIdList.add(music.musicUId);
                }
              }
            }).then((value) {
              final message = {
                "cmd": "musicList",
                "body": convert.jsonEncode(musicIdList)
              };
              channel?.sink.add(convert.jsonEncode(message));
            });
          }
          break;
        case "ready":
          final downloadList = downloadMusicFromJson(ftpCmd.body);
          musicList.addAll(downloadList);
          isRunning = true;
          break;
        case "download":
          for (var i = 0; i < musicList.length; i++) {
            final music = musicList[i];
            if (ftpCmd.body.contains(" === ")) {
              final array = ftpCmd.body.split(" === ");
              final musicUId = array[0];
              final isLast = array[1] == "true" ? true : false;
              if (music.musicUId == musicUId) {
                genFileList(music).forEach((map) {
                  final url = map["url"] ?? "";
                  final isMusic = url.contains(".flac") || url.contains(".wav");
                  pushQueue(music, url, map["dest"] ?? "", isMusic,
                      (!isMusic) ? false : isLast);
                });
              }
            } else {
              final message = ftpCmdToJson(
                  FtpCmd(cmd: "download fail", body: music.musicUId));
              channel?.sink.add(message);
              Get.back();
            }
          }
          break;
        case "stop":
        case "back":
          release();
          break;
      }
    }, onError: (e) {
      Log4f.w(msg: "连接失败");
      Log4f.e(msg: e.toString(), writeFile: true);
    }, cancelOnError: true);
    isConnected = true;
    setState(() {});
    final system = {
      "cmd": "system",
      "body": Platform.isAndroid ? "android" : "ios"
    };
    channel?.sink.add(convert.jsonEncode(system));
  }

  showBackDialog() {
    SmartDialog.compatible.show(
        widget: Container(
      width: 300.w,
      height: 150.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 250.w,
          margin: EdgeInsets.only(bottom: 30.h),
          child: Text("退出后会中断连接及传输，是否继续？", style: TextStyleMs.black_14),
        ),
        ElevatedButton(
          onPressed: () async {
            final message = ftpCmdToJson(FtpCmd(cmd: "stop", body: ""));
            channel?.sink.add(message);
            release();
          },
          child: const Text('确定'),
        )
      ]),
    ));
  }

  Widget btnFunc(String asset, String title, GestureTapCallback onTap) {
    return InkWell(
        onTap: onTap,
        child: Container(
            width: 220.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? ColorMs.color1E2328
                  : ColorMs.colorLightPrimary,
              borderRadius: BorderRadius.circular(6.h),
              boxShadow: [
                BoxShadow(
                    color: Get.isDarkMode
                        ? ColorMs.color1E2328
                        : ColorMs.colorD3E0EC,
                    offset: const Offset(5, 3),
                    blurRadius: 6),
              ],
            ),
            child: Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset(asset,
                  color: ColorMs.colorF940A7, width: 13.h, height: 20.h),
              SizedBox(width: 11.r),
              Text(title, style: TextStyleMs.pink_15)
            ]))));
  }

  release() {
    isRunning = false;
    if (queue.size > 0) {
      queue.pause();
      queue.clear();
    }
    cancelToken?.cancel();
    SmartDialog.compatible.dismiss();
    DBLogic.to
        .findAllListByGroup(GlobalLogic.to.currentGroup.value)
        .then((value) => Get.back());
  }

  @override
  void dispose() {
    musicList.clear();
    Wakelock.disable();
    channel?.sink.close();
    super.dispose();
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double _scale;
  final double _fade;

  ScaleAndFadeTransformer({double fade = 0.3, double scale = 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = info.position!;
    final scaleFactor = (1 - position.abs()) * (1 - _scale);
    final fadeFactor = (1 - position.abs()) * (1 - _fade);
    final opacity = _fade + fadeFactor;
    final scale = _scale + scaleFactor;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}
