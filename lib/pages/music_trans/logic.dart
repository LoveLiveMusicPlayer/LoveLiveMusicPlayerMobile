import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/ftp_cmd.dart';
import 'package:lovelivemusicplayer/models/ftp_music.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'dart:convert' as convert;
import 'state.dart';

class MusicTransLogic extends GetxController {
  final MusicTransState state = MusicTransState();

  Future<FtpCmd?> handlePrepareMsg(FtpCmd ftpCmd) async {
    if (ftpCmd.body.contains(" === ")) {
      final array = ftpCmd.body.split(" === ");
      final json = array[0];
      final needTransAll = array[1] == "true" ? true : false;
      final downloadList = downloadMusicFromJson(json);
      final musicIdList = <String>[];
      await Future.forEach<DownloadMusic>(downloadList, (music) async {
        if (needTransAll) {
          // 强制传输则添加到预下载列表
          musicIdList.add(music.musicUId);
        } else {
          music.musicPath = AppUtils.flac2wav(music.musicPath);
          String filePath = SDUtils.path + music.baseUrl + music.musicPath;
          if (SDUtils.checkFileExist(filePath)) {
            // 文件存在则尝试插入
            await DBLogic.to.importMusic(music);
          } else {
            // 文件不存在则添加到预下载列表
            musicIdList.add(music.musicUId);
          }
        }
      });
      return FtpCmd(cmd: "musicList", body: convert.jsonEncode(musicIdList));
    }
    return null;
  }

  List<Map<String, String>> genFileList(DownloadMusic music) {
    final baseUrl = "http://${state.ipAddress}:${state.port}/${music.baseUrl}";
    final picUrl = "$baseUrl${music.coverPath}";
    String musicUrl = "$baseUrl${music.musicPath}";

    final picDest = SDUtils.path + music.baseUrl + music.coverPath;
    String musicDest = SDUtils.path + music.baseUrl + music.musicPath;
    if (Platform.isIOS) {
      musicUrl = AppUtils.flac2wav(musicUrl);
      musicDest = AppUtils.flac2wav(musicDest);
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
    if (!state.isRunning) {
      return [];
    }

    return array;
  }

  pushQueue(DownloadMusic music, String url, String dest, bool isMusic,
      bool isLast, Function(FtpCmd) callback) async {
    await state.queue.add(() async {
      try {
        state.cancelToken = CancelToken();
        await Network.download(url, dest, (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            if (isMusic) {
              final p = double.parse(progress).truncate();
              if (state.currentProgress != p) {
                state.currentProgress = p;
                state.currentMusic = music;
                if (progress == "100") {
                  callback(FtpCmd(cmd: "download success", body: music.musicUId));
                } else {
                  if (state.isRunning) {
                    callback(FtpCmd(cmd: "downloading", body: music.musicUId));
                  }
                }
              }
            } else if (progress == "100") {
              changeNextTaskView(music);
            }
          }
        }, state.cancelToken);
        if (isMusic) {
          music.musicPath = AppUtils.flac2wav(music.musicPath);
          await DBLogic.to.importMusic(music);
        }
      } catch (e) {
        callback(FtpCmd(cmd: "download fail", body: music.musicUId));
        changeNextTaskView(music);
      }
    });
    if (isLast) {
      await state.queue.onIdle();
      callback(FtpCmd(cmd: "finish", body: ""));
      await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
      Get.back();
    }
  }

  changeNextTaskView(DownloadMusic music) {
    for (var i = 0; i < state.musicList.length; i++) {
      if (state.musicList[i].musicUId == music.musicUId) {
        if (state.index < state.musicList.length) {
          state.index = i + 1;
          state.isStartDownload = true;
          break;
        }
      }
    }
  }

  @override
  void onClose() {
    state.musicList.clear();
    super.onClose();
  }
}
