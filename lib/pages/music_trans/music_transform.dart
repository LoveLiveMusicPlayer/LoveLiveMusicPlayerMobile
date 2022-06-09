import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/models/FtpCmd.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/ftpclient.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';

class MusicTransform extends StatefulWidget {
  final IOWebSocketChannel channel = IOWebSocketChannel.connect(Uri.parse("ws://${Get.arguments}:4388"));
  // late FtpClient ftpClient;

  MusicTransform({Key? key}) : super(key: key);

  @override
  State<MusicTransform> createState() => _MusicTransformState();
}

class _MusicTransformState extends State<MusicTransform> {
  bool isPermission = false;
  String message = "";
  String progress = "";

  @override
  void initState() {
    super.initState();

    widget.channel.stream.listen((msg) async {
      final ftpCmd = ftpCmdFromJson(msg as String);
      switch (ftpCmd.cmd) {
        case "json":
          final ftpList = ftpMusicFromJson(ftpCmd.body);
          const musicList = <Music>[];
          ftpList.forEach((ftpMusic) {
            ftpMusic.music.forEach((music) {
              musicList.add(music);
            });
          });
          break;
        case "ftp open":
          // widget.ftpClient = await FtpClient().connect(Get.arguments);
          break;
        case "download":
          // final dest = SDUtils.path + "LoveLive" + Platform.pathSeparator + ftpCmd.body;
          final dest = SDUtils.path + "LoveLive/Aqours/其他/[2020.08.26] Aqours - JIMO-AI Dash!/01 - JIMO-AI Dash!.flac";
          final tempList = dest.split(Platform.pathSeparator);
          var destDir = "";
          for (var i = 0; i < tempList.length - 1; i++) {
            destDir += tempList[i] + Platform.pathSeparator;
          }
          print(dest);
          print(destDir);
          // SDUtils.makeDir(destDir);
          // Network.download("http://localhost:10005/LoveLive/Aqours/其他/[2020.08.26] Aqours - JIMO-AI Dash!/01 - JIMO-AI Dash!.flac", dest, (received, total) {
          //   if (total != -1) {
          //     final _progress = (received / total * 100).toStringAsFixed(0);
          //     progress = _progress + "%";
          //     setState(() {});
          //     if (_progress == "100") {
          //       widget.channel.sink.add('download success');
          //     }
          //   }
          // }, () {
          //   widget.channel.sink.add('download fail');
          // });

          // final isDownloadSuccess = await widget.ftpClient.download(ftpCmd.body, dest, (fileName, percent) {
          //   progress = percent.toString();
          //   setState(() {});
          // });

          // if (isDownloadSuccess) {
          //   widget.channel.sink.add('download success');
          // } else {
          //   widget.channel.sink.add('download fail');
          // }
          break;
      }
      message = msg;
      setState(() {});
    });

    widget.channel.sink.add(Platform.isAndroid ? "android" : "ios");
  }

  @override
  void dispose() {
    super.dispose();
    widget.channel.sink.close();
    // widget.ftpClient.shutdown();
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
          Text("progress: $progress"),
        ],
      );
    } else {
      requestPermission();
      return Container();
    }
  }

  requestPermission() async{
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
