import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/close_open.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/splash_photo_util.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isStartHomePage = false;
  late Widget myWidget;
  StreamSubscription? subscription;
  Timer? mTimer;
  int count = 3;

  @override
  void initState() {
    SplashPhoto splashPhoto = SplashPhoto();

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

    myWidget = SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(Assets.launchBackground),
    );
    super.initState();
    splashPhoto.genSplashList();
    final widget = splashPhoto.getRandomPhotoView();
    if (widget != null) {
      print("widget != null");
      myWidget = widget;
      setState(() {});
    }

    // 启动倒计时
    mTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        count--;
        setState(() {});
        if (count <= 0) {
          timer.cancel();
          goToHomePage();
        }
      },
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    mTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          myWidget,
          Positioned(
            bottom: 50.h,
            right: 25.w,
            child: MaterialButton(
              color: ColorMs.colorF940A7.withAlpha(100),
              highlightColor: ColorMs.color0093DF,
              colorBrightness: Brightness.dark,
              splashColor: Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Text("${"skip".tr} ${count}s"),
              onPressed: () => goToHomePage(),
            ),
          )
        ],
      ),
    );
  }

  void goToHomePage() {
    if (!isStartHomePage) {
      isStartHomePage = true;
      Get.offNamed(Routes.routeInitial);
    }
  }
}
