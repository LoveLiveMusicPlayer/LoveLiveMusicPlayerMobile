import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/drawer/drawer.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_observer.dart';
import 'package:lovelivemusicplayer/pages/player/miniplayer.dart';
import 'package:lovelivemusicplayer/pages/player/player.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/android_back_desktop.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar1.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar2.dart';
import 'package:we_slide/we_slide.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

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
  }

  @override
  void dispose() {
    GlobalLogic.mobileWeSlideController.removeListener(addListener);
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
              width: 300.w,
              child: const DrawerPage(),
            ),
            body: SafeArea(
              top: false,
              bottom: GlobalLogic.to.needHomeSafeArea.value,
              child: _weSlider(),
            )),
        onWillPop: () async {
          if (NestedController.to.currentIndex == Routes.routeHome) {
            // 首页则提示回到桌面
            if (lastPressTime == null ||
                DateTime.now().difference(lastPressTime!) >
                    const Duration(seconds: 1)) {
              //间隔时间大于1秒 则重新赋值
              lastPressTime = DateTime.now();
              SmartDialog.compatible.showToast("再次点击回到桌面");
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

  Widget _weSlider() {
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
      overlayOpacity: 0.9,
      backgroundColor: color,
      overlay: true,
      isDismissible: true,
      body: Navigator(
        key: Get.nestedKey(1),
        initialRoute: Routes.routeHome,
        onGenerateRoute: NestedController.to.onGenerateRoute,
        observers: [MyNavigator()],
      ),
      blurColor: Colors.transparent,
      overlayColor: color,
      panelHeader: MiniPlayer(onTap: () {
        if (!HomeController.to.state.isSelect.value) {
          GlobalLogic.mobileWeSlideController.show();
        }
      }),
      panel: Player(onTap: () => GlobalLogic.mobileWeSlideController.hide()),
      footer: _buildTabBarView(),
      footerHeight: 84.h,
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
    return TabBarView(
      controller: logic.tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: const [BottomBar(), BottomBar2()],
    );
  }
}
