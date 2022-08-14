import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:palette_generator/palette_generator.dart';

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

  static Future<Color?> getImagePalette(String url) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
            FileImage(File(SDUtils.path + url)));
    return paletteGenerator.mutedColor?.color;
  }
}
