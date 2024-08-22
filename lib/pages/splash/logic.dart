import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/close_open.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/splash_photo_util.dart';

class SplashLogic extends GetxController {
  SplashPhoto splashPhoto = SplashPhoto();
  bool isStartHomePage = false;
  var count = 3.obs;
  Timer? mTimer;
  Future<Widget?>? futureData;

  @override
  void onInit() {
    super.onInit();
    Completer<void> completer = Completer<void>();
    const background = AssetImage(Assets.launchBackground);
    final imageStream = background.resolve(const ImageConfiguration());
    final imageStreamListener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        // 图片加载完成时调用，解析出image对象并完成Completer
        completer.complete();
      },
    );
    imageStream.addListener(imageStreamListener);

    completer.future.then((dynamic) {
      imageStream.removeListener(imageStreamListener);
      // 发送卸载窗口命令
      eventBus.fire(CloseOpen((DateTime.now().millisecondsSinceEpoch)));
    });
  }

  @override
  void onReady() {
    super.onReady();
    futureData = fetchImageView();
  }

  Future<Widget?> fetchImageView() async {
    startTimer();
    await splashPhoto.genSplashList();
    final widget = splashPhoto.getRandomPhotoView();
    if (widget != null) {
      print("widget != null");
      return widget;
    }
    return null;
  }

  void startTimer() {
    // 启动倒计时
    mTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        count.value = count.value - 1;
        if (count <= 0) {
          timer.cancel();
          goToHomePage();
        }
      },
    );
  }

  void goToHomePage() {
    if (!isStartHomePage) {
      isStartHomePage = true;
      Get.offNamed(Routes.routeInitial);
    }
  }

  @override
  void onClose() {
    mTimer?.cancel();
    super.onClose();
  }
}
