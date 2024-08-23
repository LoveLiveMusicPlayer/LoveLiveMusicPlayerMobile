import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/cloud_data.dart';
import 'package:lovelivemusicplayer/models/cloud_update.dart';
import 'package:lovelivemusicplayer/models/ftp_music.dart';
import 'package:lovelivemusicplayer/models/group.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DrawerLogic extends GetxController {
  String getLogo(String groupName) {
    return GlobalLogic.to.getCurrentGroupIcon(groupName);
  }

  refreshList(GroupKey key) {
    final name = key.getName();
    GlobalLogic.to.currentGroup.value = name;
    DBLogic.to.findAllListByGroup(name);
  }

  Future<void> handleUpdateData() async {
    SmartDialog.showLoading(msg: 'downloading'.tr);

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      final result = await Network.getSync(Const.dataUrl, isShowDialog: false);

      if (result is List) {
        int index = -1;
        int maxNumber = 0;

        for (var i = 0; i < result.length; i++) {
          final map = CloudUpdate.fromJson(result[i]);
          if (currentNumber > maxNumber && currentNumber <= map.maxVersion) {
            maxNumber = map.maxVersion;
            index = i;
          }
        }

        if (index == -1) {
          return;
        }

        String latestDataUrl = CloudUpdate.fromJson(result[index]).url;
        final res = await Network.getSync(latestDataUrl, isShowDialog: false);

        if (res is Map<String, dynamic>) {
          CloudData data = CloudData.fromJson(res);
          int currentVersion = await SpUtil.getInt(Const.spDataVersion);

          Log4f.d(msg: "云端版本号: ${data.version}");
          await SmartDialog.dismiss(status: SmartStatus.loading);

          if (currentVersion == data.version) {
            SmartDialog.show(
              builder: (BuildContext context) => TwoButtonDialog(
                title: 'now_is_latest'.tr,
                isShowMsg: false,
                onConfirmListener: () {
                  parseUpdateDataSource(data);
                },
              ),
            );
          } else if (currentVersion < data.version) {
            parseUpdateDataSource(data);
          }
        } else {
          SmartDialog.dismiss(status: SmartStatus.loading);
          SmartDialog.showToast('data_error'.tr);
        }
      } else {
        SmartDialog.dismiss(status: SmartStatus.loading);
        SmartDialog.showToast('data_error'.tr);
      }
    } catch (err) {
      Log4f.i(msg: err.toString());
      SmartDialog.dismiss(status: SmartStatus.loading);
      SmartDialog.showToast('fetch_songs_fail'.tr);
    }
  }

  parseUpdateDataSource(CloudData data) async {
    SmartDialog.showLoading(msg: 'importing'.tr);
    await DBLogic.to.clearAllMusic();
    await DBLogic.to.artistDao.deleteAllArtists();

    await loopParseData(
        data.music.us, data.album.us, GroupKey.groupUs.getName());
    await loopParseData(
        data.music.aqours, data.album.aqours, GroupKey.groupAqours.getName());
    await loopParseData(data.music.nijigasaki, data.album.nijigasaki,
        GroupKey.groupNijigasaki.getName());
    await loopParseData(
        data.music.liella, data.album.liella, GroupKey.groupLiella.getName());
    await loopParseData(data.music.combine, data.album.combine,
        GroupKey.groupCombine.getName());
    await loopParseData(data.music.hasunosora, data.album.hasunosora,
        GroupKey.groupHasunosora.getName());
    await loopParseData(
        data.music.yohane, data.album.yohane, GroupKey.groupYohane.getName());
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
    SmartDialog.dismiss(status: SmartStatus.loading);
    SpUtil.put(Const.spDataVersion, data.version);
  }

  Future<void> loopParseData(List<InnerMusic> musicList,
      List<InnerAlbum> albumList, String group) async {
    await Future.forEach<InnerMusic>(musicList, (music) async {
      if (music.export) {
        int albumId = music.albumId;
        InnerAlbum album = albumList.firstWhere((album) => album.id == albumId);
        music.musicPath = AppUtils.flac2wav(music.musicPath);
        DownloadMusic downloadMusic = DownloadMusic(
            albumUId: album.albumUId,
            albumId: albumId,
            albumName: album.name,
            coverPath: music.coverPath,
            date: album.date,
            category: album.category,
            group: group,
            musicUId: music.musicUId,
            musicId: music.id,
            musicName: music.name,
            musicPath: music.musicPath,
            artist: music.artist,
            artistBin: music.artistBin,
            totalTime: music.time,
            baseUrl: music.baseUrl,
            neteaseId: music.neteaseId,
            existFile: checkFileExist(music));
        await DBLogic.to.importMusic(downloadMusic);
      }
    });
  }

  bool checkFileExist(InnerMusic music) {
    final musicPath = '${SDUtils.path}${music.baseUrl}${music.musicPath}';
    return File(musicPath).existsSync();
  }
}
