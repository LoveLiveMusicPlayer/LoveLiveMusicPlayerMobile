import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/ArtistModel.dart';
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
}
