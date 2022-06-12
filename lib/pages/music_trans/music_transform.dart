import 'dart:convert' as convert;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/FtpCmd.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:queue/queue.dart';

class MusicTransform extends StatefulWidget {
  final IOWebSocketChannel channel =
      IOWebSocketChannel.connect(Uri.parse("ws://${Get.arguments}:4388"));
  final queue = Queue(delay: const Duration(milliseconds: 300));

  MusicTransform({Key? key}) : super(key: key);

  @override
  State<MusicTransform> createState() => _MusicTransformState();
}

class _MusicTransformState extends State<MusicTransform> {
  bool isPermission = false;
  String message = "";
  String song = "";
  String progress = "";
  String currentMusic = "";
  final musicList = <DownloadMusic>[];
  String port = "10000";
  int total = 0;
  int currentProgress = 0;

  @override
  void initState() {
    super.initState();

    widget.channel.stream.listen((msg) async {
      final ftpCmd = ftpCmdFromJson(msg as String);
      switch (ftpCmd.cmd) {
        case "port":
          port = ftpCmd.body;
          break;
        case "json":
          final downloadList = downloadMusicFromJson(ftpCmd.body);
          total = downloadList.length;
          musicList.clear();
          musicList.addAll(downloadList);
          break;
        case "download":
          for (var music in musicList) {
            if (ftpCmd.body.contains(" === ")) {
              final array = ftpCmd.body.split(" === ");
              final musicUId = array[0];
              final isLast = array[1] == "true" ? true : false;
              if (music.musicUId == musicUId) {
                final url = "http://${Get.arguments}:$port/${music.musicPath}";
                final dest = SDUtils.path + music.musicPath;
                final tempList = dest.split(Platform.pathSeparator);
                var destDir = "";
                for (var i = 0; i < tempList.length - 1; i++) {
                  destDir += tempList[i] + Platform.pathSeparator;
                }
                SDUtils.makeDir(destDir);
                print("music: " + music.musicName + " add queue");
                await widget.queue.add(() => Network.dio!.download(url, dest));
                print("${music.musicName} download finish");
                // await widget.queue.add(() async {
                //   try {
                //     await Network.download(url, dest, (received, total) {
                //       if (total != -1) {
                //         final _progress = (received / total * 100).toStringAsFixed(0);
                //         progress = _progress + "%";
                //         song = music.musicName;
                //         setState(() {});
                //         final p = double.parse(_progress).truncate();
                //         if (currentProgress != p) {
                //           currentProgress = p;
                //           if (_progress == "100") {
                //             final message = ftpCmdToJson(FtpCmd(cmd: "download success", body: music.musicUId));
                //             print("${music.musicName} download finish");
                //             widget.channel.sink.add(message);
                //           } else {
                //             final message = ftpCmdToJson(FtpCmd(cmd: "downloading", body: "${music.musicUId} === $p"));
                //             widget.channel.sink.add(message);
                //           }
                //         }
                //       }
                //     });
                //   } catch (e) {
                //     // print("${music.musicName} is fail");
                //     final message = ftpCmdToJson(FtpCmd(cmd: "download fail", body: music.musicUId));
                //     // print("download fail: ${music.musicName}");
                //     widget.channel.sink.add(message);
                //   }
                // });
                if (isLast) {
                  await widget.queue.onComplete;
                  final message = ftpCmdToJson(FtpCmd(cmd: "finish", body: ""));
                  widget.channel.sink.add(message);
                  // print("finish");
                }
              }
            } else {
              final message = ftpCmdToJson(FtpCmd(cmd: "download fail", body: music.musicUId));
              widget.channel.sink.add(message);
            }
          }
          break;
        case "cancel":

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

  @override
  void dispose() {
    super.dispose();
    widget.channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return checkPermission();
  }

  checkPermission() {
    if (isPermission) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("message: $message"),
          Text("song: $song"),
          Text("progress: $progress"),
        ],
      );
    } else {
      requestPermission();
      return Container();
    }
  }

  requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      isPermission = true;
      setState(() {
        checkPermission();
      });
    } else {
      isPermission = false;
    }
  }
}
