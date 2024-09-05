import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/drawer/view.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/pages/home/we_slide/view.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/android_back_desktop.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/utils/umeng_helper.dart';
import 'package:lovelivemusicplayer/widgets/permission_dialog.dart';
import 'package:sharesdk_plugin/sharesdk_interface.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:umeng_push_sdk/umeng_push_sdk.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final logic = Get.find<HomeController>();
  bool isInitListener = true;

  @override
  void initState() {
    super.initState();
    logic.tabController = TabController(length: 2, vsync: this);
    logic.tabController?.addListener(() {
      final position = logic.state.currentIndex.value;
      final index = (logic.tabController?.index ?? 0) * 3 + position % 3;
      PageViewLogic.to.pageController.jumpToPage(index);
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
  Widget build(BuildContext context) {
    DateTime? lastPressTime;
    return WillPopScope(
        child: Scaffold(
            key: GlobalLogic.to.globalKey,
            resizeToAvoidBottomInset: false,
            drawerEdgeDragWidth: 0,
            endDrawer: SizedBox(
              width: min(0.35 * Get.height, Get.width),
              child: const DrawerLayout(),
            ),
            body: const WeSlideComponent()),
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
}
