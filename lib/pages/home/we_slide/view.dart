import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/close_open.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_observer.dart';
import 'package:lovelivemusicplayer/pages/home/we_slide/logic.dart';
import 'package:lovelivemusicplayer/pages/player/miniplayer.dart';
import 'package:lovelivemusicplayer/pages/player/player/view.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar/bottom_bar1.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar/bottom_bar2.dart';
import 'package:we_slide/we_slide.dart';

class WeSlideComponent extends StatefulWidget {
  const WeSlideComponent({super.key});

  @override
  State<WeSlideComponent> createState() => _WeSlideComponentState();
}

class _WeSlideComponentState extends State<WeSlideComponent> {
  final logic = Get.put(WeSlideLogic());

  ImageStream? imageStream;
  ImageStreamListener? imageStreamListener;
  Completer<void> completer = Completer<void>();

  @override
  void initState() {
    super.initState();
    imageStreamListener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        // 图片加载完成时调用，解析出image对象并完成Completer
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    completer.future.then((dynamic) {
      if (!GlobalLogic.to.hasAIPic) {
        // 没有AI开屏时发送卸载窗口命令
        eventBus.fire(CloseOpen((DateTime.now().millisecondsSinceEpoch)));
      }
    });

    GlobalLogic.mobileWeSlideController.addListener(addListener);
    GlobalLogic.mobileWeSlideFooterController.addListener(addFooterListener);
  }

  DecorationImage? loadDecorationImage(String photo) {
    if (photo == "") {
      if (!completer.isCompleted) {
        completer.complete();
      }
      return null;
    }
    DecorationImage di =
        DecorationImage(image: FileImage(File(photo)), fit: BoxFit.cover);
    imageStream = di.image.resolve(const ImageConfiguration());
    imageStream?.addListener(imageStreamListener!);
    return di;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalLogic>(
      assignId: true,
      builder: (logic) {
        final photo = logic.bgPhoto.value;
        return Container(
          decoration: BoxDecoration(image: loadDecorationImage(photo)),
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
            body: Navigator(
              key: Get.nestedKey(1),
              initialRoute: Routes.routeHome,
              onGenerateRoute: NestedController.to.onGenerateRoute,
              observers: [HeroController(), MyNavigator()],
            ),
            blurColor: Colors.transparent,
            overlayColor: Theme.of(context).primaryColor,
            panelHeader: MiniPlayer(onTap: () {
              if (HomeController.to.state.selectMode.value == 0) {
                GlobalLogic.openPanel();
              }
            }),
            panel: const PlayerPage(onTap: GlobalLogic.closePanel),
            footer: _buildTabBarView(),
            footerHeight: logic.needHomeSafeArea.value ? 67.h : 77.h,
            blur: true,
            parallax: true,
            isUpSlide: false,
            transformScale: true,
            fadeSequence: [
              TweenSequenceItem<double>(
                  weight: 1.0, tween: Tween(begin: 1, end: 0)),
              TweenSequenceItem<double>(
                  weight: 8.0, tween: Tween(begin: 0, end: 0)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBarView() {
    return GetBuilder<HomeController>(
      assignId: true,
      builder: (logic) {
        return TabBarView(
          controller: logic.tabController,
          physics: logic.state.selectMode.value > 0
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          children: const [BottomBar1(), BottomBar2()],
        );
      },
    );
  }

  addListener() {
    final isOpen = GlobalLogic.mobileWeSlideController.isOpened;
    if (isOpen == true) {
      // 如果Panel打开，则隐藏BottomBar
      GlobalLogic.closeBottomBar();
    } else if (NestedController.isHomePage) {
      GlobalLogic.openBottomBar();
    }

    eventBus.fire(
        PlayerClosableEvent(GlobalLogic.mobileWeSlideController.isOpened));
  }

  addFooterListener() {
    bool needHomeSafeArea = !NestedController.isHomePage &&
        !GlobalLogic.mobileWeSlideController.isOpened;
    if (GlobalLogic.to.needHomeSafeArea.value != needHomeSafeArea) {
      GlobalLogic.to.needHomeSafeArea.value = needHomeSafeArea;
      setState(() {});
    }
  }

  @override
  void dispose() {
    Get.delete<WeSlideLogic>();
    GlobalLogic.mobileWeSlideController.removeListener(addListener);
    if (imageStreamListener != null) {
      imageStream?.removeListener(imageStreamListener!);
    }
    imageStream = null;
    super.dispose();
  }
}
