import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class AppUtils {
  /// 异步获取歌单封面
  static Future<String> getMusicCoverPath(String? musicPath) async {
    final defaultPath = SDUtils.getImgPath();
    if (musicPath == null) {
      return defaultPath;
    }
    final music = await DBLogic.to.findMusicById(musicPath);
    if (music == null) {
      return defaultPath;
    }
    return SDUtils.path + music.baseUrl! + music.coverPath!;
  }

  /// 图片提取主色
  static Future<Color?> getImagePalette(String url) async {
    final image =
        await getImageFromProvider(FileImage(File(SDUtils.path + url)));
    final rgb = await getColorFromImage(image);
    return Color.fromARGB(150, rgb?.elementAt(0) ?? 0, rgb?.elementAt(1) ?? 0,
        rgb?.elementAt(2) ?? 0);
  }

  /// 图片提取主色
  static Future<Color?> getImagePalette2(String url) async {
    final image = await getImageFromProvider(AssetImage(url));
    final rgb = await getColorFromImage(image);
    return Color.fromARGB(150, rgb?.elementAt(0) ?? 0, rgb?.elementAt(1) ?? 0,
        rgb?.elementAt(2) ?? 0);
  }

  /// 删除网络图片缓存
  static Future<dynamic> removeNetImageCache(String url) async {
    return await CachedNetworkImage.evictFromCache(url);
  }
}
