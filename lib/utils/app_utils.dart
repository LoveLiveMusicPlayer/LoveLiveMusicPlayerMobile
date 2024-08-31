import 'dart:convert';
import 'dart:io';
import 'dart:ui' as dart_ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:common_utils/common_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/global/global_theme.dart';
import 'package:lovelivemusicplayer/models/artist_model.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/share_menu.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';
import 'package:sharesdk_plugin/sharesdk_plugin.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

class AppUtils {
  static CacheManager cacheManager = CacheManager(Config("imgSplash"));

  static changeTheme(bool isNight, {bool? enableAuto}) async {
    if (enableAuto != null) {
      GlobalLogic.to.withSystemTheme.value = enableAuto;
    }
    GlobalLogic.to.isDarkTheme.value = isNight;

    if (GlobalLogic.to.withSystemTheme.value) {
      Get.changeThemeMode(ThemeMode.system);
      Get.changeTheme(isNight ? darkTheme : lightTheme);
    } else {
      Get.changeThemeMode(isNight ? ThemeMode.dark : ThemeMode.light);
      Get.changeTheme(isNight ? darkTheme : lightTheme);
    }

    if (enableAuto != null) {
      await SpUtil.put(Const.spWithSystemTheme, enableAuto);
    }
    await SpUtil.put(Const.spDark, isNight);
  }

  static reloadApp() {
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      Get.forceAppUpdate().then((value) {
        PageViewLogic.to.pageController
            .jumpToPage(HomeController.to.state.currentIndex.value);
      });
    });
  }

  /// 禁用 Android WebView Inspect
  static Future<void> disableWebDebugger() async {
    PlatformInAppWebViewController.debugLoggingSettings.enabled = false;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(false);
    }
  }

  /// 异步获取歌单封面
  static Future<String?> getMusicCoverPath(String? musicPath) async {
    final defaultPath = SDUtils.getImgPath();
    if (musicPath == null) {
      return defaultPath;
    }
    final music = await DBLogic.to.findMusicById(musicPath);
    if (music == null) {
      return defaultPath;
    }
    String? path;
    if (music.existFile == true) {
      path = "${SDUtils.path}${music.baseUrl}${music.coverPath}";
    } else if (GlobalLogic.to.remoteHttp.canUseHttpUrl()) {
      path =
          "${GlobalLogic.to.remoteHttp.httpUrl.value}${music.baseUrl}${music.coverPath}";
    }
    return path;
  }

  /// 图片提取主色
  static Future<Color?> getImagePalette(String url,
      [Color? defaultColor]) async {
    final path = url.contains(SDUtils.path) ? url : SDUtils.path + url;
    final file = File(path);
    if (!file.existsSync()) {
      return defaultColor ?? GlobalLogic.to.iconColor.value;
    }
    final image = await getImageFromProvider(FileImage(file));
    final rgb = await getColorFromImage(image, 1);
    return Color.fromARGB(150, rgb?.elementAt(0) ?? 0, rgb?.elementAt(1) ?? 0,
        rgb?.elementAt(2) ?? 0);
  }

  /// Music提取主色
  static Future<Color?> getImagePaletteFromMusic(Music music) async {
    dart_ui.Image? image;
    if (music.existFile == true) {
      final path = "${SDUtils.path}${music.baseUrl}${music.coverPath}";
      image = await getImageFromProvider(FileImage(File(path)));
    } else {
      if (GlobalLogic.to.remoteHttp.canUseHttpUrl()) {
        final path =
            "${GlobalLogic.to.remoteHttp.httpUrl.value}${music.baseUrl}${music.coverPath}";
        image = await getImageFromProvider(NetworkImage(path));
      }
    }
    if (image == null) {
      return null;
    }
    final rgb = await getColorFromImage(image, 1);
    return Color.fromARGB(150, rgb?.elementAt(0) ?? 0, rgb?.elementAt(1) ?? 0,
        rgb?.elementAt(2) ?? 0);
  }

  /// 图片提取主色
  static Future<Color?> getImagePalette2(String url) async {
    final image = await getImageFromProvider(AssetImage(url));
    final rgb = await getColorFromImage(image, 1);
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

  // 动态隐藏状态栏和导航栏
  static hideStateBarAndNavigationBar() {
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  static setHighPerformanceForAndroid() {
    // 强制设置高帧率
    if (Platform.isAndroid) {
      FlutterDisplayMode.setHighRefreshRate();
    }
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
    SpUtil.getString(Const.spPrevPage).then((prevPage) {
      if (prevPage == "") {
        return;
      }
      UmengCommonSdk.onPageEnd(prevPage);
      UmengCommonSdk.onPageStart(page);
      SpUtil.put(Const.spPrevPage, page);
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

  /// version1 老版本号
  /// version2 新版本号
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
    SmartDialog.showLoading(msg: "loading".tr);
    late String text;
    late String title;
    String params = "";
    String path = "";
    if (music == null && menu == null) {
      text = "";
      title = "share_app".tr;
    } else {
      if (music != null) {
        title = "outer_share_music".tr;
        text = music.musicName!;
        final shareMusic = SharedMusic(
            id: music.musicId!,
            name: music.musicName!,
            neteaseId: music.neteaseId);
        params = "?type=1&data=${shareMusicToJson(shareMusic)}";
        try {
          if (Platform.isIOS) {
            path = SDUtils.path + music.baseUrl! + music.coverPath!;
          } else {
            final res = await Network.getSync(
                "${Const.backendUrl}?ids=${music.neteaseId}");
            path = res["songs"][0]["al"]["picUrl"];
          }
        } catch (_) {}
      } else if (menu != null) {
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

        final value = shareMenuToJson(shareMenu);
        final key = sha512.convert(utf8.encode(value));

        final obj = {"key": "$key", "value": value};

        final resp = await Network.postSync(Const.shareKvUrl, obj);
        if (resp["success"] == true) {
          params = "?type=2&data=$key";
          final firstMusic = await DBLogic.to.findMusicById(menu.music.first);
          if (firstMusic != null) {
            try {
              if (Platform.isIOS) {
                path =
                    SDUtils.path + firstMusic.baseUrl! + firstMusic.coverPath!;
              } else {
                final res = await Network.getSync(
                    "${Const.backendUrl}?ids=${firstMusic.neteaseId}");
                path = res["songs"][0]["al"]["picUrl"];
              }
            } catch (_) {}
          }
        } else {
          return;
        }
      }
    }

    if (path.isEmpty) {
      path = Const.shareDefaultLogo;
    } else if (path.startsWith("http")) {
    } else if (!SDUtils.checkFileExist(path)) {
      path = Const.shareDefaultLogo;
    }
    SmartDialog.dismiss();

    SSDKMap sdkMap = SSDKMap()
      ..setQQ(
          text,
          title,
          // Uri.encodeFull("http://192.168.123.19:8080/#/$params"),
          Uri.encodeFull("https://shareqq.zhushenwudi.top/#/$params"),
          "",
          "",
          "",
          "",
          path,
          path,
          "",
          "",
          "",
          "",
          "",
          SSDKContentTypes.webpage,
          ShareSDKPlatforms.qq);
    SharesdkPlugin.share(ShareSDKPlatforms.qq, sdkMap, (SSDKResponseState state,
        dynamic userdata, dynamic contentEntity, SSDKError error) {
      Log4f.i(msg: "错误码: ${error.code}");
      Log4f.i(msg: "错误原因: ${error.rawData}");
      SmartDialog.showToast("${"share_error".tr} ${error.code}");
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

  static handleShare(uri) async {
    final path = Uri.decodeQueryComponent(uri.toString());
    final json = jsonEncode(Uri.parse(path).queryParameters);
    Log4f.d(msg: '获取到的uri: $json');
    final obj = jsonDecode(json);
    switch (obj["type"]) {
      case null:
        // 仅打开APP
        break;
      case "1":
        // 传递单曲
        final musicId = obj["musicId"];
        final music = await DBLogic.to.findMusicById(musicId);
        if (music == null) {
          SmartDialog.showToast("no_found_music1".tr);
          return;
        }
        SmartDialog.show(builder: (context) {
          return TwoButtonDialog(
            isShowImg: false,
            title: "need_play_share_music".tr,
            msg: music.musicName,
            onConfirmListener: () {
              PlayerLogic.to.playMusic([music]);
            },
          );
        });
        break;
      case "2":
        // 传递歌单
        final data = obj["data"];
        final json = jsonDecode(data);
        List<String> musicIds = [];
        json["musicIds"].forEach((musicId) {
          musicIds.add(musicId);
        });
        final tempArr = <String>[];
        await Future.forEach<String>(musicIds, (musicId) async {
          final music = await DBLogic.to.findMusicById(musicId);
          if (music != null && music.musicId != null) {
            tempArr.add(music.musicId!);
          }
        });
        if (tempArr.isEmpty) {
          SmartDialog.showToast("no_found_music2".tr);
          return;
        }
        final menuName = json["menuName"];
        SmartDialog.show(builder: (context) {
          return TwoButtonDialog(
            isShowImg: false,
            title: "need_import_share_menu".tr,
            msg: menuName,
            onConfirmListener: () async {
              bool isSuccess = await DBLogic.to.addMenu(menuName, tempArr);
              SmartDialog.showToast(
                  isSuccess ? 'create_success'.tr : 'create_over_max'.tr);
            },
          );
        });
        break;
    }
  }

  static flac2wav(String? path) {
    if (Platform.isIOS) {
      return path?.replaceAll(".flac", ".wav");
    }
    return path;
  }

  static wav2flac(String? path) {
    return path?.replaceAll(".wav", ".flac");
  }

  static vibrate() async {
    final canVibrate = await Haptics.canVibrate();
    if (!canVibrate) {
      return;
    }
    if (Platform.isAndroid) {
      await Haptics.vibrate(HapticsType.warning);
    } else {
      await Haptics.vibrate(HapticsType.medium);
    }
  }

  static isPre(Function func) {
    if (GlobalLogic.to.env == "pre") {
      func();
    }
  }
}
