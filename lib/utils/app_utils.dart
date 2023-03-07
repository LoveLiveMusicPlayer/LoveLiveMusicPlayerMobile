import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/ArtistModel.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/models/ShareMenu.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:sharesdk_plugin/sharesdk_plugin.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

class AppUtils {
  static CacheManager cacheManager =
      CacheManager(Config("imgSplash", stalePeriod: const Duration(days: 1)));

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
    final path = url.contains(SDUtils.path) ? url : SDUtils.path + url;
    final image = await getImageFromProvider(FileImage(File(path)));
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

  /// 判断缓存中是否存在该URL
  static Future<bool> checkUrlExist(url) async {
    try {
      await cacheManager.getSingleFile(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 计算101...200中，数组内不存在的最小值
  static int calcSmallAtIntArr(List<int> idList) {
    var result = -1;
    idList.sort();
    for (var i = 101; i <= 200; i++) {
      if (!idList.contains(i)) {
        result = i;
        break;
      }
    }
    return result;
  }

  static int comparePeopleNumber(String one, String two) {
    final firstOneChar = one.substring(0, 1);
    if (firstOneChar == "U") {
      return 1;
    }
    final firstTwoChar = two.substring(0, 1);
    if (firstTwoChar == "U") {
      return -1;
    }
    final firstOneNum = int.parse(firstOneChar);
    final firstTwoNum = int.parse(firstTwoChar);
    if (firstOneNum != firstTwoNum) {
      return firstOneNum - firstTwoNum;
    }

    final otherOneBinNum = int.parse(one.substring(1, one.length), radix: 36);
    final otherTwoBinNum = int.parse(two.substring(1, two.length), radix: 36);
    final oneCount = _getBinCountWithOne(otherOneBinNum);
    final twoCount = _getBinCountWithOne(otherTwoBinNum);
    if (oneCount != twoCount) {
      return oneCount - twoCount;
    }

    final otherOneDecNum = int.parse(otherOneBinNum.toRadixString(2));
    final otherTwoDecNum = int.parse(otherTwoBinNum.toRadixString(2));
    return otherOneDecNum - otherTwoDecNum;
  }

  static List<ArtistModel> parseArtistBin(String? musicBin,
      List<ArtistModel> artistList, Map<String, String> singleMap) {
    if (musicBin == null) {
      return [];
    }
    final firstChar = musicBin.substring(0, 1);
    if (firstChar == "U") {
      final hexList = musicBin.substring(1).split("0x");
      final resultList = <ArtistModel>[];
      artistList
          .where((artistModel) =>
              hexList.any((hex) => artistModel.v == singleMap["0x$hex"]))
          .forEach((result) {
        resultList.add(result);
      });
      return resultList;
    }
    final tempList = <ArtistModel>[];
    final musicBinStr = musicBin.substring(1);
    final musicBinDec = int.parse(musicBinStr, radix: 36);
    if (_isMultiSong(musicBinDec)) {
      for (var i = 0; i < artistList.length; i++) {
        final artist = artistList[i];
        final artistBinStr = artist.v.substring(1);
        final artistBinFirstChar = artist.v.substring(0, 1);
        if (artistBinFirstChar != firstChar) {
          continue;
        }
        final artistBin = int.parse(artistBinStr, radix: 36);
        if (musicBinDec == artistBin) {
          tempList.clear();
          tempList.add(artist);
          break;
        } else {
          if (!_isMultiSong(artistBin) &&
              (musicBinDec & artistBin) == artistBin) {
            tempList.add(artist);
          }
        }
      }
    } else {
      for (var i = 0; i < artistList.length; i++) {
        final artist = artistList[i];
        final artistBinStr = artist.v.substring(1);
        final artistBin = int.parse(artistBinStr, radix: 36);
        final artistBinFirstChar = artist.v.substring(0, 1);
        if (artistBinFirstChar != firstChar) {
          continue;
        }
        if (musicBinDec == artistBin) {
          tempList.add(artist);
          break;
        }
      }
    }
    return tempList;
  }

  static _getBinCountWithOne(int number) {
    var count = 0;
    while (number != 0) {
      number = number & (number - 1);
      count++;
    }
    return count;
  }

  static _isMultiSong(int number) {
    var count = 0;
    while (number != 0) {
      number = number & (number - 1);
      count++;
    }
    return count > 1;
  }

  /// 设置状态栏
  static setStatusBar(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent));
  }

  static uploadEvent(String eventName, {Map<String, String>? params}) {
    UmengCommonSdk.onEvent(
        eventName,
        params ??
            {
              "time":
                  DateUtil.formatDate(DateTime.now(), format: DateFormats.full)
            });
  }

  static uploadPageStart(String page) {
    SpUtil.getString("prevPage").then((prevPage) {
      if (prevPage == "") {
        return;
      }
      UmengCommonSdk.onPageEnd(prevPage);
      UmengCommonSdk.onPageStart(page);
      SpUtil.put("prevPage", page);
    });
  }

  ///数字转成Int
  ///[number] 可以是String 可以是int 可以是double 出错了就返回0;
  static num2int(number) {
    try {
      if (number is String) {
        return int.parse(number);
      } else if (number is int) {
        return number;
      } else if (number is double) {
        return number.toInt();
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  ///数字转成double
  ///[number] 可以是String 可以是int 可以是double 出错了就返回0;
  static num2double(number) {
    try {
      if (number is String) {
        return double.parse(number);
      } else if (number is int) {
        return number.toDouble();
      } else if (number is double) {
        return number;
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

  /// version1 新版本号
  /// version2 老版本号
  ///
  static bool compareVersion(String version1, String version2) {
    int i = 0, j = 0;
    while (i < version1.length || j < version2.length) {
      int num1 = 0;
      while (i < version1.length && version1[i] != '.') {
        num1 = num1 * 10 + int.parse(version1[i]);
        i++;
      }
      int num2 = 0;
      while (j < version2.length && version2[j] != '.') {
        num2 = num2 * 10 + int.parse(version2[j]);
        j++;
      }
      if (num1 != num2) {
        return num1 < num2;
      }
      i++;
      j++;
    }
    return false;
  }

  static Future<void> shareQQ({Music? music, Menu? menu}) async {
    if (music != null && menu != null) {
      return;
    }
    late String text;
    late String title;
    late String params;
    String path = "";
    if (music == null && menu == null) {
      text = "";
      title = "share_app".tr;
      params = "open-app";
    } else {
      if (music != null) {
        title = "outer_share_music".tr;
        text = music.musicName!;
        final shareMusic = SharedMusic(
            id: music.musicId!,
            name: music.musicName!,
            neteaseId: music.neteaseId);
        params = Uri.encodeFull("play?data=${shareMusicToJson(shareMusic)}");
        path = SDUtils.path + music.baseUrl! + music.coverPath!;
      } else if (menu != null) {
        SmartDialog.compatible.showLoading(msg: 'loading'.tr);
        title = "outer_share_menu".tr;
        text = menu.name;
        final musicList = await DBLogic.to.findMusicByMusicIds(menu.music);
        List<SharedMusic> shareMusicList = [];
        for (var music in musicList) {
          final shareMusic = SharedMusic(
              id: music.musicId!,
              name: music.musicName!,
              neteaseId: music.neteaseId);
          shareMusicList.add(shareMusic);
        }
        final shareMenu =
            ShareMenu(menuName: menu.name, musicList: shareMusicList);
        params = Uri.encodeFull("share?data=${shareMenuToJson(shareMenu)}");
        final firstMusic = await DBLogic.to.findMusicById(menu.music.first);
        if (firstMusic != null) {
          path = SDUtils.path + firstMusic.baseUrl! + firstMusic.coverPath!;
        }
        SmartDialog.compatible.dismiss();
      }
    }

    if (path.isEmpty || !SDUtils.checkFileExist(path)) {
      path = Const.shareDefaultLogo;
    }
    print("--------------");
    print(params);

    SSDKMap sdkMap = SSDKMap()
      ..setQQ(
          text,
          title,
          "http://192.168.123.19:8080/$params",
          // "https://shareqq.zhushenwudi.top/$params",
          "",
          "",
          "",
          "",
          path,
          "",
          "",
          "",
          "",
          "",
          "",
          SSDKContentTypes.webpage,
          ShareSDKPlatforms.qq);
    SharesdkPlugin.share(ShareSDKPlatforms.qq, sdkMap, (SSDKResponseState state,
        dynamic userdata, dynamic contentEntity, SSDKError error) {
      print(error.rawData);
      switch (error.code) {
        case 200104:
          SmartDialog.compatible.showToast("no_qq".tr);
          break;
        default:
          break;
      }
    });
  }

  static Map? getArtistIndexArrInGroup(String artistStr) {
    final firstOneChar = artistStr.substring(0, 1);
    if (firstOneChar == "U") {
      return null;
    }
    final artistDecNum =
        int.parse(artistStr.substring(1, artistStr.length), radix: 36);
    final artistBin = int.parse(artistDecNum.toRadixString(2)).toString();
    return {
      "group": firstOneChar,
      "artistBin": artistBin.split('').reversed.join('')
    };
  }
}
