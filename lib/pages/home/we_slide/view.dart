import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_observer.dart';
import 'package:lovelivemusicplayer/pages/home/we_slide/logic.dart';
import 'package:lovelivemusicplayer/pages/player/mini_player/view.dart';
import 'package:lovelivemusicplayer/pages/player/player/view.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar/bottom_bar1.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar/bottom_bar2.dart';
import 'package:we_slide/we_slide.dart';

class WeSlideComponent extends GetView<WeSlideLogic> {
  const WeSlideComponent({super.key});

  @override
  Widget build(BuildContext context) {
    // 这里提取出来，防止频繁刷新产生列表重绘，严重影响性能
    final body = Navigator(
      key: Get.nestedKey(1),
      initialRoute: Routes.routeHome,
      onGenerateRoute: NestedController.to.onGenerateRoute,
      observers: [HeroController(), MyNavigator()],
    );
    return Obx(() {
      final photo = GlobalLogic.to.bgPhoto.value;
      return Container(
        decoration: BoxDecoration(image: controller.loadDecorationImage(photo)),
        child: WeSlide(
          controller: GlobalLogic.mobileWeSlideController,
          footerController: GlobalLogic.mobileWeSlideFooterController,
          panelMinSize: 150.h,
          panelMaxSize: ScreenUtil().screenHeight,
          backgroundColor: photo.isEmpty
              ? Theme.of(context).primaryColor
              : const Color(0x00000000)
                  .withOpacity(Get.isDarkMode ? 0.4 : 0.15),
          overlay: true,
          body: body,
          blurColor: Colors.transparent,
          overlayColor: Theme.of(context).primaryColor,
          panelHeader: MiniPlayer(controller.miniPlayerTapCover),
          panel: PlayerPage(onTap: controller.panelTapCloseButton),
          footer: TabBarView(
            controller: HomeController.to.tabController,
            physics: HomeController.to.state.selectMode.value > 0
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            children: const [BottomBar1(), BottomBar2()],
          ),
          footerHeight: GlobalLogic.to.needHomeSafeArea.value ? 57.h : 77.h,
          blur: true,
          parallax: true,
          isUpSlide: false,
          transformScale: true,
          fadeSequence: [
            TweenSequenceItem(weight: 1.0, tween: Tween(begin: 1, end: 0)),
            TweenSequenceItem(weight: 8.0, tween: Tween(begin: 0, end: 0)),
          ],
        ),
      );
    });
  }
}
