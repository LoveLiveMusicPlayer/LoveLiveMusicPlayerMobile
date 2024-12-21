import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_binding.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/models/box_decoration.dart';
import 'package:lovelivemusicplayer/models/group.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/remote_http.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/desktop_lyric_util.dart';
import 'package:lovelivemusicplayer/utils/home_widget_util.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:we_slide/we_slide.dart';

class GlobalLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  /// all、μ's、Aqours、Nijigasaki、Liella!、Combine
  final currentGroup = GroupKey.groupAll.getName().obs;
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

  // 当前环境
  var env = "prod";

  // 传输协议
  var transVer = 1;

  // 记录本次升级是否需要清空数据库
  var needClearApp = false;

  // 是否可以使用SmartDialog
  var isCanUseSmartDialog = false;

  /// 主页是否需要预留底部安全区域
  var needHomeSafeArea = false.obs;

  /// 是否正在处理播放逻辑
  var isHandlePlay = false;

  /// 是否使用封面皮肤
  var hasSkin = false.obs;

  /// 是否跟随系统主题色
  var withSystemTheme = false.obs;

  // 主题是否是深色模式
  var isDarkTheme = false.obs;

  // 排序模式(asc: 按时间顺序, desc: 按时间倒序)
  var sortMode = "".obs;

  /// 炫彩模式下的按钮皮肤
  var iconColor = Get.theme.primaryColorDark.obs;

  // 是否有AI开屏
  var hasAIPic = false;

  // 是否打开桌面歌词
  var openDesktopLyric = false;

  // APP版本号
  var appVersion = "1.0.0";

  // 是否允许显示背景图片
  var enableBG = false;

  // 远端http服务
  late RemoteHttp remoteHttp;

  static GlobalLogic get to => Get.find();

  /// 定时关闭功能
  Timer? timer;
  ButtonController? timerController;
  var remainTime = ValueNotifier<int>(0);

  @override
  void onInit() {
    super.onInit();

    /// widget树构建完毕后执行
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      refreshIconColor();
      PlayerLogic.to.miniPlayerBoxDecorationData = BoxDecorationData(
              color: Get.theme.primaryColor.value, borderRadius: 34.r)
          .obs;
    });

    /// 监听系统主题色改变
    final window = WidgetsBinding.instance.platformDispatcher;
    window.onPlatformBrightnessChanged = () async {
      bool isDark = window.platformBrightness == Brightness.dark;
      if (withSystemTheme.value) {
        AppUtils.changeTheme(isDark);
      }
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
      AppUtils.reloadApp();
    };
  }

  /// 初始化服务等一系列耗时任务
  initServices() async {
    appVersion = (await PackageInfo.fromPlatform()).version;
    Log4f.getLogger();
    Get.log = defaultLogWriterCallback;
    await GetStorage.init();
    SpUtil.getInstance();
    Network.getInstance();
    await SDUtils.init();
    if (Platform.isAndroid) {
      // android 需要额外注册 usb 插拔事件监听、桌面歌词点击监听
      await SDUtils.setUsbMountListener();
      DesktopLyricUtil.init();
    }
    remoteHttp = RemoteHttp(await SpUtil.getBoolean(Const.spEnableHttp),
        await SpUtil.getString(Const.spHttpUrl, ""));
    enableBG = await SpUtil.getBoolean(Const.spEnableBackgroundPhoto);
    if (enableBG) {
      SpUtil.getString(Const.spBackgroundPhoto).then((value) {
        if (SDUtils.checkFileExist(SDUtils.bgPhotoPath + value)) {
          setBgPhoto(SDUtils.bgPhotoPath + value);
        }
      });
    }
    hasAIPic = await SpUtil.getBoolean(Const.spAIPicture, true);
    openDesktopLyric = await SpUtil.getBoolean(Const.spOpenDesktopLyric, false);
    await DesktopLyricUtil.invokeStatus(openDesktopLyric);
    sortMode.value = await SpUtil.getString(Const.spSortOrder, "ASC");
    hasSkin.value = await SpUtil.getBoolean(Const.spColorful);
    isDarkTheme.value = await SpUtil.getBoolean(Const.spDark);
    withSystemTheme.value = await SpUtil.getBoolean(Const.spWithSystemTheme);
    await SpUtil.put(Const.spPrevPage, "");
    PlayerBinding().dependencies();
    await HomeWidgetUtil.init();
  }

  refreshIconColor() async {
    final mContext = Get.context;
    bool isDark = false;
    if (mContext == null || !mContext.mounted) {
      return;
    }
    isDark = MediaQuery.of(mContext).platformBrightness == Brightness.dark;
    Color color = const Color(Const.noMusicColorfulSkin);
    final musicList = PlayerLogic.to.mPlayList;
    if (musicList.isNotEmpty) {
      final playListMusic = musicList[PlayerLogic.to.mPlayer.currentIndex ?? 0];
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

  List<Music> filterMusicListByIndex(index) {
    switch (index) {
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
    return Const.groupList.getLogo(currentGroup);
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
    if (withSystemTheme) {
      bool isDark =
          MediaQuery.of(Get.context!).platformBrightness == Brightness.dark;
      color = isDark ? darkColor : lightColor;
    } else {
      color = isDarkTheme.value ? darkColor : lightColor;
    }
    return color!;
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

  static openPanel() {
    mobileWeSlideController.show();
  }

  static closePanel() {
    mobileWeSlideController.hide();
  }

  static openBottomBar() {
    mobileWeSlideFooterController.show();
  }

  static closeBottomBar() {
    mobileWeSlideFooterController.hide();
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {
    // 这个函数进入前台还是进入后台都会被调用
  }

  @override
  void onPaused() {
    // 在 onInactive 之后被调用
  }

  @override
  void onResumed() {
    // 在 onInactive 之后被调用
    /// 防止长时间熄屏 PageView 重建回到首页
    try {
      scrollTo(HomeController
          .scrollControllers[HomeController.to.state.currentIndex.value]);

      PageViewLogic.to.pageController
          .jumpToPage(HomeController.to.state.currentIndex.value);
    } catch (_) {}
  }

  @override
  void onHidden() {}
}
