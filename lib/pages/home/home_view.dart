import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/drawer/view.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/pages/home/we_slide/view.dart';
import 'package:lovelivemusicplayer/utils/android_back_desktop.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final logic = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    logic.tabController = TabController(length: 2, vsync: this);
    logic.tabController?.addListener(() {
      final position = logic.state.currentIndex.value;
      final index = (logic.tabController?.index ?? 0) * 3 + position % 3;
      PageViewLogic.to.pageController.jumpToPage(index);
    });
    logic.handlePermission();
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
          if (NestedController.isHomePage) {
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
