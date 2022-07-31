import 'dart:convert' as convert;
import 'dart:io';

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:concurrent_queue/concurrent_queue.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/FtpCmd.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/album_details/widget/details_header.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/circle_widget.dart';
import 'package:lovelivemusicplayer/widgets/horizontal_line.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/io.dart';

class MusicTransform extends StatefulWidget {
  final IOWebSocketChannel channel =
      IOWebSocketChannel.connect(Uri.parse("ws://${Get.arguments}:4388"));
  final queue = ConcurrentQueue(concurrency: 1);

  MusicTransform({Key? key}) : super(key: key);

  @override
  State<MusicTransform> createState() => _MusicTransformState();
}

class _MusicTransformState extends State<MusicTransform> {
  bool isPermission = false;

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

  // banner控制器，无作用，但是必须加，代码控制时也需要这个
  final controller = TransformerPageController();

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    widget.channel.stream.listen((msg) {
      final ftpCmd = ftpCmdFromJson(msg as String);
      switch (ftpCmd.cmd) {
        case "noTrans":
          isNoTrans = true;
          musicList.addAll(downloadMusicFromJson(ftpCmd.body));
          isStartDownload = true;
          setState(() {});
          Future.forEach<DownloadMusic>(musicList, (music) async {
            if (File(SDUtils.path + music.musicPath).existsSync()) {
              currentMusic = music;
              changeNextTaskView(music);
              setState(() {});
              await DBLogic.to.insertMusicIntoAlbum(music);
            }
          }).then((_) {
            DBLogic.to.findAllListByGroup("all").then((value) => Get.back());
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

            for (var music in downloadList) {
              if (needTransAll) {
                musicIdList.add(music.musicUId);
              } else if (!SDUtils.checkFileExist(
                  SDUtils.path + music.musicPath)) {
                musicIdList.add(music.musicUId);
              }
            }
            final message = {
              "cmd": "musicList",
              "body": convert.jsonEncode(musicIdList)
            };
            widget.channel.sink.add(convert.jsonEncode(message));
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
                genFileList(music).forEach((url, dest) {
                  final isPic = url.contains("jpg");
                  pushQueue(music, url, dest, isPic ? false : isLast);
                });
              }
            } else {
              final message = ftpCmdToJson(
                  FtpCmd(cmd: "download fail", body: music.musicUId));
              widget.channel.sink.add(message);
              Get.back();
            }
          }
          break;
        case "stop":
        case "back":
          release();
          break;
      }
    });

    final system = {
      "cmd": "system",
      "body": Platform.isAndroid ? "android" : "ios"
    };
    widget.channel.sink.add(convert.jsonEncode(system));
  }

  Map<String, String> genFileList(DownloadMusic music) {
    final musicUrl = "http://${Get.arguments}:$port/${music.musicPath}";
    final picUrl = "http://${Get.arguments}:$port/${music.coverPath}";
    final musicDest = SDUtils.path + music.musicPath;
    final picDest = SDUtils.path + music.coverPath;
    final tempList = musicDest.split(Platform.pathSeparator);
    var destDir = "";
    for (var i = 0; i < tempList.length - 1; i++) {
      destDir += tempList[i] + Platform.pathSeparator;
    }
    SDUtils.makeDir(destDir);
    if (!isRunning) {
      return {};
    }
    return {picUrl: picDest, musicUrl: musicDest};
  }

  pushQueue(DownloadMusic music, String url, String dest, bool isLast) async {
    final isMusic = url.endsWith("flac") || url.endsWith("wav");
    await widget.queue.add(() async {
      try {
        cancelToken = CancelToken();
        await Network.download(url, dest, (received, total) {
          if (total != -1) {
            final _progress = (received / total * 100).toStringAsFixed(0);
            if (isMusic) {
              final p = double.parse(_progress).truncate();
              if (currentProgress != p) {
                currentProgress = p;
                currentMusic = music;
                if (_progress == "100") {
                  final message = ftpCmdToJson(
                      FtpCmd(cmd: "download success", body: music.musicUId));
                  widget.channel.sink.add(message);
                } else {
                  if (isRunning) {
                    final message = ftpCmdToJson(
                        FtpCmd(cmd: "downloading", body: music.musicUId));
                    widget.channel.sink.add(message);
                  }
                }
                setState(() {});
              }
            } else if (_progress == "100") {
              changeNextTaskView(music);
            }
          }
        }, cancelToken);
        if (isMusic) {
          DBLogic.to.insertMusicIntoAlbum(music);
        }
      } catch (e) {
        final message =
            ftpCmdToJson(FtpCmd(cmd: "download fail", body: music.musicUId));
        widget.channel.sink.add(message);
        changeNextTaskView(music);
        setState(() {});
      }
    });
    if (isLast) {
      await widget.queue.onIdle();
      final message = ftpCmdToJson(FtpCmd(cmd: "finish", body: ""));
      widget.channel.sink.add(message);
      await DBLogic.to.findAllListByGroup("all");
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
  void dispose() {
    musicList.clear();
    Wakelock.disable();
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: body(),
        onWillPop: () async {
          showBackDialog();
          return false;
        });
  }

  body() {
    if (isPermission) {
      return Scaffold(
          body: Column(
        children: [
          DetailsHeader(title: '歌曲快传', onBack: () => showBackDialog()),
          SizedBox(height: 35.h),
          drawBody(),
          SizedBox(height: 20.h),
          drawMusicInfo(),
          SizedBox(height: 40.h),
          drawProgressBar()
        ],
      ));
    } else {
      requestPermission();
      return Container();
    }
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
          child: const Image(image: AssetImage(Assets.assetsLogo)));
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
            return showImg(
                SDUtils.getImgPath(musicList[index].coverPath), 400, 400,
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
                completeColor: const Color(0xFFF940A7),
                lineColors: [const Color(0xFFF940A7)],
                completeWidth: 8.w,
                width: 1.w,
                isDividerRound: true,
                lineColor: const Color(0xFFF940A7),
              ),
            ),
          ),
        ),

        /// 外圈
        CustomPaint(
          size: Size(190.h, 190.h),
          painter: CircleView(
            completePercent: 100,
            completeColor: const Color(0x1AF940A7),
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
                color: const Color(0xFFCCDDF1)),
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
            widget.channel.sink.add(message);
            release();
          },
          child: const Text('确定'),
        )
      ]),
    ));
  }

  release() {
    isRunning = false;
    if (widget.queue.size > 0) {
      widget.queue.pause();
      widget.queue.clear();
    }
    cancelToken?.cancel();
    SmartDialog.dismiss();
    DBLogic.to
        .findAllListByGroup(GlobalLogic.to.currentGroup.value)
        .then((value) => Get.back());
  }

  requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      isPermission = true;
      setState(() {
        body();
      });
    } else {
      isPermission = false;
    }
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
