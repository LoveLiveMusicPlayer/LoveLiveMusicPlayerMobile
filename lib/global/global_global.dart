import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_theme.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';

import '../models/Music.dart';

class GlobalLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  /// all、μ's、Aqours、Nijigasaki、Liella!、Combine
  final currentGroup = "all".obs;
  final databaseInitOver = false.obs;

  final musicList = <Music>[].obs;
  final albumList = <Album>[].obs;
  final artistList = <Artist>[].obs;
  final loveList = <Music>[].obs;
  final menuList = <Menu>[].obs;
  final recentlyList = <Music>[].obs;

  /// 是否正在处理播放逻辑
  var isHandlePlay = false;

  /// 是否手动选择的是暗色主题
  var manualIsDark = false.obs;

  /// 是否使用封面皮肤
  var hasSkin = false.obs;

  /// 是否跟随系统主题色
  var withSystemTheme = false.obs;

  /// 炫彩模式下的按钮皮肤
  var iconColor = Get.theme.primaryColorDark.obs;

  /// 程序是否在后台（因为这个回调进入后台时也会被调用，所以该变量用于判断系统更改主题后，只有回到前台后才能修改）
  var isBackground = false;

  static GlobalLogic get to => Get.find();

  @override
  void onInit() {
    super.onInit();

    /// widget树构建完毕后执行
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      hasSkin.value = await SpUtil.getBoolean(Const.spColorful, false);
      manualIsDark.value = await SpUtil.getBoolean(Const.spDark, false);
      bool isWith = await SpUtil.getBoolean(Const.spWithSystemTheme, false);
      bool isDark =
          MediaQuery.of(Get.context!).platformBrightness == Brightness.dark;
      if (isWith) {
        Get.changeTheme(isDark ? darkTheme : lightTheme);
      }
      iconColor.value = isDark
          ? const Color(0xFF1E2328)
          : const Color(Const.noMusicColorfulSkin);
      withSystemTheme.value = isWith;
    });

    /// 监听系统主题色改变
    final window = WidgetsBinding.instance.window;
    window.onPlatformBrightnessChanged = () async {
      if (isBackground) {
        // 后台不允许执行下面的方法
        return;
      }
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
      bool isWith = await SpUtil.getBoolean(Const.spWithSystemTheme, false);
      bool isDark = window.platformBrightness == Brightness.dark;
      if (isWith && Get.context != null) {
        Get.changeTheme(isDark ? darkTheme : lightTheme);
      }
      withSystemTheme.value = isWith;
    };
  }

  int getListSize(int index, bool isDbInit) {
    if (!isDbInit) {
      return 0;
    }
    switch (index) {
      case 0:
        return musicList.length;
      case 1:
        return albumList.length;
      case 2:
        return artistList.length;
      case 3:
        return loveList.length;
      case 4:
        return menuList.length;
      case 5:
        return recentlyList.length;
      default:
        return 0;
    }
  }

  RxList getList(int index) {
    switch (index) {
      case 0:
        return musicList;
      case 1:
        return albumList;
      case 2:
        return artistList;
      case 3:
        return loveList;
      case 4:
        return menuList;
      case 5:
        return recentlyList;
      default:
        return [].obs;
    }
  }

  setList(int index, List<dynamic> itemList) {
    switch (index) {
      case 0:
        musicList.value = itemList.cast();
        break;
      case 1:
        albumList.value = itemList.cast();
        break;
      case 2:
        artistList.value = itemList.cast();
        break;
      case 3:
        loveList.value = itemList.cast();
        break;
      case 4:
        menuList.value = itemList.cast();
        break;
      case 5:
        recentlyList.value = itemList.cast();
        break;
      default:
        break;
    }
  }

  List<Music> filterMusicListByAlbums(menuIndex) {
    switch (menuIndex) {
      case 0:
        return musicList;
      case 1:
        List<Music> tempList = [];
        for (var album in albumList) {
          for (var music in musicList) {
            if (music.albumId == album.albumId) {
              tempList.add(music);
            }
          }
        }
        return tempList;
      case 3:
        return loveList;
      case 5:
        return recentlyList;
      default:
        return [];
    }
  }

  String getCurrentGroupIcon(String currentGroup) {
    switch (currentGroup) {
      case "μ's":
        return Assets.logoLogoUs;
      case "Aqours":
        return Assets.logoLogoAqours;
      case "Nijigasaki":
        return Assets.logoLogoNiji;
      case "Liella!":
        return Assets.logoLogoLiella;
      case "Combine":
        return Assets.logoLogoCombine;
      default:
        return Assets.logoLogo;
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {
    // 这个函数进入前台还是进入后台都会被调用
    isBackground = false;
  }

  @override
  void onPaused() {
    // 在 onInactive 之后被调用
    isBackground = true;
  }

  @override
  void onResumed() {
    // 在 onInactive 之后被调用
    isBackground = false;

    /// 防止长时间熄屏 PageView 重建回到首页
    switch (HomeController.to.state.currentIndex.value) {
      case 0:
        scrollTo(HomeController.to.scrollController1);
        break;
      case 1:
        scrollTo(HomeController.to.scrollController2);
        break;
      case 2:
        scrollTo(HomeController.to.scrollController3);
        break;
      case 3:
        scrollTo(HomeController.to.scrollController4);
        break;
      case 4:
        scrollTo(HomeController.to.scrollController5);
        break;
      case 5:
        scrollTo(HomeController.to.scrollController6);
        break;
    }
    PageViewLogic.to.controller
        .jumpToPage(HomeController.to.state.currentIndex.value);
  }

  scrollTo(ScrollController controller) {
    try {
      controller.animateTo(0,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
    } catch (e) {
      Log4f.e(msg: e.toString());
    }
  }
}
