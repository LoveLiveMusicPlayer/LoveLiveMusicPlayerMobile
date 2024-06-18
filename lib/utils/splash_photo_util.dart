import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/models/download_splash.dart';
import 'package:lovelivemusicplayer/models/init_config.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class SplashPhoto {
  // 开屏图片列表
  var splashList = <String>[];
  final downloadList = <DownloadSplash>[];

  Widget? getRandomPhotoView() {
    if (splashList.isEmpty) {
      return null;
    }
    splashList.shuffle();
    String imageUrl = splashList[0];
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.file(File(imageUrl),
          fit: BoxFit.cover, alignment: Alignment.topCenter),
    );
  }

  /// 获取资源oss url，解析开屏图片数据
  genSplashList() async {
    try {
      // 从splash文件夹中获取已缓存的图片列表
      splashList = [...SDUtils.getSplashPhotoList()];

      final result = await Network.getSync(Const.splashConfigUrl);
      if (result is Map<String, dynamic>) {
        // 能够加载到开屏配置
        final config = initConfigFromJson(jsonEncode(result));
        Const.dataOssUrl = config.ossUrl;
        Const.splashUrl = config.ossUrl + config.splash.route;
        final forceMap = config.splash.forceChoose;

        // 先将全部图片放到列表中
        await addAllSplashPhoto(config);
        SDUtils.downloadSplashList(downloadList);

        if (forceMap == null) {
          return;
        }

        final endTime = forceMap["endTime"];
        if (endTime != null &&
            endTime < DateTime.now().millisecondsSinceEpoch) {
          return;
        }
        final forceId = forceMap["uid"];
        if (forceId == null) {
          return;
        }
        final forceBg = config.splash.bg
            .firstWhereOrNull((bg) => bg.uid == forceMap["uid"]);
        if (forceBg == null) {
          return;
        }
        final index = forceMap["index"];
        if (index == null || index < 0 || index > forceBg.size) {
          return;
        }

        final path =
            "${SDUtils.splashPhotoPath}${forceBg.singer}/bg_${forceBg.singer}_$index.png";
        final mIndex = splashList.indexOf(path);
        if (mIndex >= 0) {
          // 缓存列表存在强制开屏图，清空数组并将其重新添加
          splashList.clear();
          splashList.add(path);
        }
      }
    } catch (e) {
      Log4f.d(msg: e.toString());
    }
  }

  /// 将可用开屏界面地址全部添加到开屏图列表中
  Future<void> addAllSplashPhoto(InitConfig config) async {
    downloadList.clear();
    await Future.forEach(config.splash.bg, (Bg bg) async {
      var size = List<int>.generate(bg.size, (index) => index + 1);
      await Future.forEach(size, (index) async {
        final photoUrl =
            "${Const.splashUrl}${bg.singer}/bg_${bg.singer}_$index.png";
        final photoPath = SDUtils.splashPhotoPath + photoUrl.split("/").last;
        final isExist = SDUtils.checkFileExist(photoPath);
        if (!isExist) {
          downloadList.add(DownloadSplash(photoUrl, photoPath));
        }
      });
    });
  }
}
