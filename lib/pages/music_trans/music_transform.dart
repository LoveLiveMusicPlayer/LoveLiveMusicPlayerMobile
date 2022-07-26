import 'dart:convert' as convert;
import 'dart:io';

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:concurrent_queue/concurrent_queue.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/FtpCmd.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
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
  String message = "";
  DownloadMusic? currentMusic;
  final musicList = <DownloadMusic>[];
  String port = "10000";
  int currentProgress = 0;
  bool isRunning = false;
  CancelToken? cancelToken;
  final picList = <String>[];
  int index = 0;
  bool isStartDownload = false;
  final controller = TransformerPageController();

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    widget.channel.stream.listen((msg) {
      final ftpCmd = ftpCmdFromJson(msg as String);
      switch (ftpCmd.cmd) {
        case "noTrans":
          Future.forEach<DownloadMusic>(downloadMusicFromJson(ftpCmd.body), (music) async {
            if (File(SDUtils.path + music.musicPath).existsSync()) {
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
                  if (isPic) {
                    picList.add(dest);
                    if (i == musicList.length - 1) {
                      isStartDownload = true;
                    }
                  }
                  pushQueue(
                      music, url, dest, isPic ? false : isLast);
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
          isRunning = false;
          widget.queue.clear();
          musicList.clear();
          cancelToken?.cancel();
          SmartDialog.dismiss();
          DBLogic.to.findAllListByGroup("all").then((value) => Get.back());
          break;
        case "back":
          Get.back();
          break;
      }
      message = msg;
      setState(() {});
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
          if (total != -1 && isMusic) {
            final _progress = (received / total * 100).toStringAsFixed(0);
            final p = double.parse(_progress).truncate();
            if (currentProgress != p) {
              currentProgress = p;
              currentMusic = music;
              if (_progress == "100") {
                final message = ftpCmdToJson(
                    FtpCmd(cmd: "download success", body: music.musicUId));
                widget.channel.sink.add(message);
                changeNextTaskView(isMusic, music);
              } else {
                if (isRunning) {
                  final message = ftpCmdToJson(
                      FtpCmd(cmd: "downloading", body: music.musicUId));
                  widget.channel.sink.add(message);
                }
              }
              setState(() {});
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
        changeNextTaskView(isMusic, music);
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

  changeNextTaskView(bool isMusic, DownloadMusic music) {
    if (isMusic) {
      for (var i = 0; i < musicList.length; i++) {
        if (musicList[i].musicUId == music.musicUId) {
          if (index < picList.length - 1) {
            index = i + 1;
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.channel.sink.close();
    musicList.clear();
    Wakelock.disable();
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
      double percent = 0;
      int current = 0;
      int total = 0;
      if (isStartDownload) {
        current = index + 1;
        total = picList.length;
        percent = current / total * 100;
      }
      return Scaffold(
        body: Column(
          children: [
            DetailsHeader(title: '歌曲快传' ,onBack: () => showBackDialog()),
            SizedBox(height: 35.h),
            drawBody(),
            SizedBox(height: 20.h),
            drawMusicInfo(),
            SizedBox(height: 50.h),
            Stack(
              children: [
                SizedBox(
                  width: 190.w,
                  height: 190.w,
                  child: Center(
                    child: CustomPaint(
                      size: Size(160.w, 160.w),
                      painter: CircleView(
                        completePercent: percent.roundToDouble(),
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
                CustomPaint(
                  size: Size(190.w, 190.w),
                  painter: CircleView(
                    completePercent: 100,
                    completeColor: const Color(0x1AF940A7),
                    lineColors: [],
                    completeWidth: 8.w,
                  ),
                ),
                SizedBox(
                  width: 190.w,
                  height: 190.w,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("$current", style: Get.isDarkMode ? TextStyleMs.white_15 : TextStyleMs.black_15),
                        SizedBox(height: 15.h),
                        HorizontalLine(dashedHeight: 1.h, dashedWidth: 70.w, color: const Color(0xFFCCDDF1)),
                        SizedBox(height: 15.h),
                        Text("$total", style: Get.isDarkMode ? TextStyleMs.white_15 : TextStyleMs.black_15)
                      ],
                    )
                  ),
                )
              ],
            )
          ],
        )
      );
    } else {
      requestPermission();
      return Container();
    }
  }

  Widget drawMusicInfo() {
    if (currentMusic == null) {
      return SizedBox(height: 40.h);
    } else {
      return SizedBox(
        height: 40.h,
        child: Column(
          children: [
            Text(currentMusic!.musicName, style: Get.isDarkMode ? TextStyleMs.white_15 : TextStyleMs.black_15),
            Text(currentMusic!.artist, style: TextStyleMs.gray_12),
          ],
        ),
      );
    }
  }

  Widget drawBody() {
    if (picList.isEmpty) {
      return Container(
        width: 300.w,
        height: 300.w,
        color: Get.theme.primaryColor,
      );
    } else {
      return SizedBox(
        width: 300.w,
        height: 300.w,
        child: TransformerPageView(
          index: index,
          viewportFraction: 0.8,
          pageController: controller,
          transformer: ScaleAndFadeTransformer(),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Image.file(File(picList[index]), fit: BoxFit.fill);
          },
          itemCount: picList.length,
        ),
      );
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
                SmartDialog.dismiss();
                await DBLogic.to.findAllListByGroup("all");
                Get.back();
              },
              child: const Text('确定'),
            )
          ]),
        ));
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
