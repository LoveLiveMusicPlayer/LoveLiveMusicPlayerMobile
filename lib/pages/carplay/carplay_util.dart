import 'dart:collection';

import 'package:flutter_carplay/models/list/list_item.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_enum.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:uuid/uuid.dart';

class CarplayUtil {
  static CarplayPageType page = CarplayPageType.pageMain;
  static bool isTouchFromCar = false;

  static LinkedHashMap<String, String> groupMap =
      LinkedHashMap<String, String>.from({
    Const.groupUs: Assets.logoLogoUs,
    Const.groupAqours: Assets.logoLogoAqours,
    Const.groupSaki: Assets.logoLogoNiji,
    Const.groupLiella: Assets.logoLogoLiella,
    Const.groupHasunosora: Assets.logoLogoHasunosora,
    Const.groupYohane: Assets.logoLogoYohane,
    Const.groupCombine: Assets.logoLogoCombine
  });

  static String genUniqueId(String? musicId) {
    return musicId ?? const Uuid().v4();
  }

  static String convertToMainName(String group) {
    String name = "";
    switch (group) {
      case Const.groupSaki:
        name = "虹咲学园学园偶像同好会";
        break;
      case Const.groupHasunosora:
        name = "莲之空女学院";
        break;
      case Const.groupYohane:
        name = "幻日夜羽";
        break;
      case Const.groupCombine:
        name = "其他";
        break;
      default:
        name = group;
        break;
    }
    return splitName(name);
  }

  static String convertToDetailName(String group) {
    String name = "";
    switch (group) {
      case Const.groupUs:
        name = "ラブライブ！";
        break;
      case Const.groupAqours:
        name = "ラブライブ！サンシャイン!!";
        break;
      case Const.groupSaki:
        name = "虹ヶ咲学園スクールアイドル同好会";
        break;
      case Const.groupLiella:
        name = "ラブライブ！スーパースター!!";
        break;
      case Const.groupHasunosora:
        name = "蓮ノ空女学院スクールアイドルクラブ";
        break;
      case Const.groupYohane:
        name = "幻日のヨハネ -SUNSHINE in the MIRROR-";
        break;
      case Const.groupCombine:
        name = "u咩";
        break;
      default:
        name = group;
        break;
    }
    return splitName(name);
  }

  static String splitName(String name) {
    String title;
    const maxTitleLength = 30;
    if (name.length > maxTitleLength) {
      title = "${name.substring(0, maxTitleLength)}...";
    } else {
      title = name;
    }
    return title;
  }

  static String music2Image(Music? music) {
    String? imagePath;
    if (music != null) {
      if (music.existFile == true) {
        imagePath = "file://${SDUtils.path}${music.baseUrl}${music.coverPath}";
      } else if (remoteHttp.canUseHttpUrl()) {
        imagePath =
            "${remoteHttp.httpUrl.value}${music.baseUrl}${music.coverPath}";
      }
    }
    return imagePath ?? Assets.logoLogo;
  }

  static String album2Image(Album album) {
    String? imagePath;
    if (remoteHttp.canUseHttpUrl()) {
      imagePath = "${remoteHttp.httpUrl.value}${album.coverPath}";
    } else {
      imagePath = "file://${SDUtils.path}${album.coverPath}";
    }
    return imagePath;
  }

  static Future<List<Music>> cpList2MusicList(List<CPListItem> cpList) async {
    List<String> idList = [];
    for (var element in cpList) {
      idList.add(element.uniqueId);
    }
    return await DBLogic.to.findMusicByMusicIds(idList);
  }
}
