import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/close_open.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/drawer/view.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_observer.dart';
import 'package:lovelivemusicplayer/pages/player/miniplayer.dart';
import 'package:lovelivemusicplayer/pages/player/player.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/android_back_desktop.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/utils/umeng_helper.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar1.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar2.dart';
import 'package:lovelivemusicplayer/widgets/permission_dialog.dart';
import 'package:sharesdk_plugin/sharesdk_interface.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:umeng_push_sdk/umeng_push_sdk.dart';
import 'package:we_slide/we_slide.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final logic = Get.find<HomeController>();
  bool isInitListener = true;

  static ImageStream? imageStream;
  ImageStreamListener? imageStreamListener;

  @override
  void initState() {
    super.initState();
    logic.tabController = TabController(length: 2, vsync: this);
    logic.tabController?.addListener(() {
      final position = HomeController.to.state.currentIndex.value;
      final index = (logic.tabController?.index ?? 0) * 3 + position % 3;
      PageViewLogic.to.controller.jumpToPage(index);
    });
    handlePermission();
  }

  void handlePermission() {
    SpUtil.getBoolean(Const.spAllowPermission).then((hasPermission) {
      if (!hasPermission) {
        SmartDialog.show(
            backDismiss: false,
            clickMaskDismiss: false,
            builder: (context) {
              return PermissionDialog(readPermission: () async {
                await Get.toNamed(Routes.routePermission);
                handlePermission();
              }, confirm: () {
                SpUtil.put(Const.spAllowPermission, true);
                initSDK();
              });
            });
      } else {
        initSDK();
      }
    });
  }

  initSDK() {
    UmengPushSdk.setLogEnable(true);
    UmengCommonSdk.initCommon(
        '634bd9c688ccdf4b7e4ac67b', '634bdfd305844627b56670a1', 'Umeng');
    UmengCommonSdk.setPageCollectionModeManual();
    SharesdkPlugin.uploadPrivacyPermissionStatus(1, (success) {});
    AppUtils.uploadEvent("Home");

    if (Platform.isAndroid) {
      UmengPushSdk.setTokenCallback((deviceToken) {
        AppUtils.isPre(() => print("deviceToken: $deviceToken"));
      });
    }

    UmengPushSdk.setNotificationCallback((receive) {}, (open) {
      final json = jsonDecode(open);
      final data = json["data"];
      Get.toNamed(Routes.routeDaily, arguments: data);
    });

    UmengHelper.agree().then((value) {
      UmengPushSdk.register("5f69a20ba246501b677d0923", "IOS");
      UmengPushSdk.getRegisteredId().then((deviceToken) {
        AppUtils.isPre(() => print("deviceToken: $deviceToken"));
      });
    });
  }

  @override
  void dispose() {
    GlobalLogic.mobileWeSlideController.removeListener(addListener);
    if (imageStreamListener != null) {
      imageStream?.removeListener(imageStreamListener!);
    }
    imageStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressTime;
    return WillPopScope(
        child: Scaffold(
            key: GlobalLogic.to.globalKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: GlobalLogic.to.needHomeSafeArea.value
                ? Get.theme.primaryColor
                : Colors.white,
            endDrawer: SizedBox(
              width: min(0.35 * Get.height, Get.width),
              child: const DrawerLayout(),
            ),
            body: GetBuilder<GlobalLogic>(builder: (logic) {
              final photo = logic.bgPhoto.value;
              final color = Theme.of(context).primaryColor;
              DecorationImage? di;
              Completer<void> completer = Completer<void>();
              if (photo != "") {
                di = DecorationImage(
                    image: FileImage(File(photo)), fit: BoxFit.cover);

                imageStream = di.image.resolve(const ImageConfiguration());
                imageStreamListener = ImageStreamListener(
                  (ImageInfo imageInfo, bool synchronousCall) {
                    // 图片加载完成时调用，解析出image对象并完成Completer
                    completer.complete();
                  },
                );
                imageStream?.addListener(imageStreamListener!);
              } else {
                completer.complete();
              }
              completer.future.then((dynamic) {
                if (!GlobalLogic.to.hasAIPic) {
                  // 没有AI开屏时发送卸载窗口命令
                  eventBus
                      .fire(CloseOpen((DateTime.now().millisecondsSinceEpoch)));
                }
              });
              return Container(
                decoration: BoxDecoration(image: di),
                child: ColorfulSafeArea(
                  color: photo == ""
                      ? color
                      : const Color(0x00000000)
                          .withOpacity(Get.isDarkMode ? 0.4 : 0.15),
                  top: false,
                  bottom: GlobalLogic.to.needHomeSafeArea.value,
                  child: _weSlider(photo),
                ),
              );
            })),
        onWillPop: () async {
          if (NestedController.to.currentIndex == Routes.routeHome) {
            // 首页则提示回到桌面
            if (lastPressTime == null ||
                DateTime.now().difference(lastPressTime!) >
                    const Duration(seconds: 1)) {
              //间隔时间大于1秒 则重新赋值
              lastPressTime = DateTime.now();
              SmartDialog.showToast('click_again_to_back'.tr);
              return false;
            }
            AndroidBackDesktop.backToDesktop();
          } else {
            // 返回首页
            Get.back(id: 1);
          }
          return false;
        });
  }

  Widget _weSlider(String photo) {
    const double panelMinSize = 150;
    final double panelMaxSize = ScreenUtil().screenHeight;
    final color = Theme.of(context).primaryColor;
    if (isInitListener) {
      isInitListener = false;
      GlobalLogic.mobileWeSlideController.addListener(addListener);
      GlobalLogic.mobileWeSlideFooterController.addListener(addFooterListener);
    }
    return WeSlide(
      controller: GlobalLogic.mobileWeSlideController,
      footerController: GlobalLogic.mobileWeSlideFooterController,
      panelMinSize: panelMinSize.h,
      panelMaxSize: panelMaxSize,
      overlayOpacity: 0,
      backgroundColor: photo == ""
          ? color
          : const Color(0x00000000).withOpacity(Get.isDarkMode ? 0.4 : 0.15),
      overlay: true,
      isDismissible: true,
      body: Navigator(
        key: Get.nestedKey(1),
        initialRoute: Routes.routeHome,
        onGenerateRoute: NestedController.to.onGenerateRoute,
        observers: [HeroController(), MyNavigator()],
      ),
      blurColor: Colors.transparent,
      overlayColor: color,
      panelHeader: MiniPlayer(onTap: () {
        if (HomeController.to.state.selectMode.value == 0) {
          GlobalLogic.mobileWeSlideController.show();
        }
      }),
      panel: Player(onTap: () => GlobalLogic.mobileWeSlideController.hide()),
      footer: _buildTabBarView(),
      footerHeight: 77.h,
      blur: true,
      parallax: true,
      isUpSlide: false,
      transformScale: true,
      blurSigma: 5.0,
      fadeSequence: [
        TweenSequenceItem<double>(weight: 1.0, tween: Tween(begin: 1, end: 0)),
        TweenSequenceItem<double>(weight: 8.0, tween: Tween(begin: 0, end: 0)),
      ],
    );
  }

  addListener() {
    if (GlobalLogic.mobileWeSlideController.isOpened == true) {
      GlobalLogic.mobileWeSlideFooterController.hide();
    } else if (NestedController.to.currentIndex == Routes.routeHome) {
      GlobalLogic.mobileWeSlideFooterController.show();
    }

    addFooterListener();

    eventBus.fire(
        PlayerClosableEvent(GlobalLogic.mobileWeSlideController.isOpened));
  }

  addFooterListener() {
    if (NestedController.to.currentIndex != Routes.routeHome &&
        !GlobalLogic.mobileWeSlideController.isOpened) {
      // 不在主界面 && 歌词页没有展开
      GlobalLogic.to.needHomeSafeArea.value = true;
    } else {
      GlobalLogic.to.needHomeSafeArea.value = false;
    }
    setState(() {});
  }

  Widget _buildTabBarView() {
    return Obx(() {
      return TabBarView(
        controller: logic.tabController,
        physics: HomeController.to.state.selectMode.value > 0
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        children: const [BottomBar(), BottomBar2()],
      );
    });
  }
}
