import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/global/global_theme.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:we_slide/we_slide.dart';

class GlobalLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  /// all、μ's、Aqours、Nijigasaki、Liella!、Combine
  final currentGroup = Const.groupAll.obs;
  final databaseInitOver = false.obs;

  final musicList = <Music>[].obs;
  final albumList = <Album>[].obs;
  final artistList = <Artist>[].obs;
  final loveList = <Music>[].obs;
  final menuList = <Menu>[].obs;
  final recentList = <Music>[].obs;
  final bgPhoto = "".obs;

  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  static final mobileWeSlideController = WeSlideController();
  static final mobileWeSlideFooterController = WeSlideController(initial: true);

  /// 主页是否需要预留底部安全区域
  var needHomeSafeArea = false.obs;

  /// 是否正在处理播放逻辑
  var isHandlePlay = false;

  /// 是否手动选择的是暗色主题
  var manualIsDark = false.obs;

  /// 是否使用封面皮肤
  var hasSkin = false.obs;

  /// 是否跟随系统主题色
  var withSystemTheme = false.obs;

  var isDarkTheme = false.obs;

  /// 炫彩模式下的按钮皮肤
  var iconColor = Get.theme.primaryColorDark.obs;

  /// 程序是否在后台（因为这个回调进入后台时也会被调用，所以该变量用于判断系统更改主题后，只有回到前台后才能修改）
  var isBackground = false;

  static GlobalLogic get to => Get.find();

  /// 定时关闭功能
  Timer? timer;
  ButtonController? timerController;
  var remainTime = ValueNotifier<int>(0);

  @override
  void onInit() {
    super.onInit();

    /// widget树构建完毕后执行
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      hasSkin.value = await SpUtil.getBoolean(Const.spColorful, false);
      manualIsDark.value = await SpUtil.getBoolean(Const.spDark, false);
      bool isWith = await SpUtil.getBoolean(Const.spWithSystemTheme, false);
      final mContext = Get.context;
      bool isDark = false;
      if (mContext != null) {
        if (!mContext.mounted) return;
        isDark = MediaQuery.of(mContext).platformBrightness == Brightness.dark;
        if (isWith) {
          Get.changeTheme(isDark ? darkTheme : lightTheme);
        }
      }

      Color color = const Color(Const.noMusicColorfulSkin);
      final musicList = PlayerLogic.to.mPlayList;
      if (musicList.isNotEmpty) {
        final playListMusic =
            musicList[PlayerLogic.to.mPlayer.currentIndex ?? 0];
        final music =
            await DBLogic.to.musicDao.findMusicByUId(playListMusic.musicId);
        if (music != null) {
          final tempColor = await AppUtils.getImagePaletteFromMusic(music);
          color = tempColor ?? color;
        }
      }
      iconColor.value = hasSkin.value
          ? color
          : isDark
              ? ColorMs.color1E2328
              : ColorMs.colorLightPrimary;
      withSystemTheme.value = isWith;
      Future.delayed(const Duration(milliseconds: 500))
          .then((value) => isThemeDark(init: true));
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

    SpUtil.getBoolean(Const.spEnableBackgroundPhoto).then((value) {
      if (value) {
        SpUtil.getString(Const.spBackgroundPhoto).then((value) {
          if (SDUtils.checkFileExist(SDUtils.bgPhotoPath + value)) {
            setBgPhoto(SDUtils.bgPhotoPath + value);
          }
        });
      }
    });
  }

  setBgPhoto(String photoPath) {
    bgPhoto.value = photoPath;
    refresh();
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
        return recentList.length;
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
        return recentList;
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
        recentList.value = itemList.cast();
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
        return recentList;
      default:
        return [];
    }
  }

  String getCurrentGroupIcon(String currentGroup) {
    switch (currentGroup) {
      case Const.groupUs:
        return Assets.logoLogoUs;
      case Const.groupAqours:
        return Assets.logoLogoAqours;
      case Const.groupSaki:
        return Assets.logoLogoNiji;
      case Const.groupLiella:
        return Assets.logoLogoLiella;
      case Const.groupCombine:
        return Assets.logoLogoCombine;
      case Const.groupHasunosora:
        return Assets.logoLogoHasunosora;
      case Const.groupYohane:
        return Assets.logoLogoYohane;
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
    try {
      scrollTo(HomeController
          .scrollControllers[HomeController.to.state.currentIndex.value]);

      PageViewLogic.to.controller
          .jumpToPage(HomeController.to.state.currentIndex.value);
    } catch (_) {}
  }

  scrollTo(ScrollController controller) {
    try {
      controller.animateTo(0,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  Color getThemeColor(Color? darkColor, Color? lightColor) {
    Color? color;
    final withSystemTheme = GlobalLogic.to.withSystemTheme.value;
    final manualIsDark = GlobalLogic.to.manualIsDark.value;
    if (withSystemTheme) {
      bool isDark =
          MediaQuery.of(Get.context!).platformBrightness == Brightness.dark;
      color = isDark ? darkColor : lightColor;
    } else {
      color = manualIsDark ? darkColor : lightColor;
    }
    return color!;
  }

  isThemeDark({bool init = false}) {
    final withSystemTheme = GlobalLogic.to.withSystemTheme.value;
    final manualIsDark = GlobalLogic.to.manualIsDark.value;
    if (withSystemTheme) {
      isDarkTheme.value =
          MediaQuery.of(Get.context!).platformBrightness == Brightness.dark;
    } else {
      isDarkTheme.value = manualIsDark;
    }
    if (init) {
      Get.forceAppUpdate();
    }
  }

  void startTimer(int? number) {
    if (number == null || number < 0) {
      return;
    }
    remainTime.value = number;
    if (number == 0) {
      timerController?.setTextValue = 'timed_to_stop'.tr;
      _stopTimer();
    } else {
      timerController?.setTextValue =
          "${'timed_to_stop_remain'.tr}${remainTime.value}${'minutes'.tr}";
      timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
        remainTime.value--;
        Log4f.d(msg: "睡眠模式-倒计时:${remainTime.value}分钟");
        if (remainTime.value <= 0) {
          timerController?.setTextValue = 'timed_to_stop'.tr;
          if (PlayerLogic.to.mPlayer.playing) {
            PlayerLogic.to.mPlayer.pause();
            PlayerLogic.to.mPlayer.stop();
          }
          t.cancel();
        } else {
          timerController?.setTextValue =
              "${'timed_to_stop_remain'.tr}${remainTime.value}${'minutes'.tr}";
        }
      });
    }
  }

  void _stopTimer() {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
  }

  @override
  void onHidden() {}
}
