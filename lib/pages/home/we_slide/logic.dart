import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/close_open.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';

class WeSlideLogic extends GetxController {
  ImageStream? imageStream;
  ImageStreamListener? imageStreamListener;
  Completer<void> completer = Completer<void>();

  @override
  void onInit() {
    super.onInit();
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

    GlobalLogic.mobileWeSlideController.addListener(addPanelListener);
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

  addPanelListener() {
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
    }
  }

  miniPlayerTapCover() {
    if (HomeController.to.state.selectMode.value == 0) {
      GlobalLogic.openPanel();
    }
  }

  panelTapCloseButton() {
    GlobalLogic.closePanel();
  }

  @override
  void onClose() {
    GlobalLogic.mobileWeSlideController.removeListener(addPanelListener);
    GlobalLogic.mobileWeSlideFooterController.removeListener(addFooterListener);
    if (imageStreamListener != null) {
      imageStream?.removeListener(imageStreamListener!);
      imageStreamListener = null;
    }
    imageStream = null;
    super.onClose();
  }
}
