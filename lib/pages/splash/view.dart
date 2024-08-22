import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/pages/splash/logic.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

class SplashPage extends GetView<SplashLogic> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Stack(
          children: [
            FutureBuilder<Widget?>(
              initialData: renderEmptyUI(),
              builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasError) {
                  return renderEmptyUI(); // 加载状态
                } else {
                  return snapshot.data ?? renderEmptyUI(); // 数据状态
                }
              },
              future: controller.futureData,
            ),
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
                child: Obx(() {
                  return Text("${"skip".tr} ${controller.count}s");
                }),
                onPressed: () => controller.goToHomePage(),
              ),
            )
          ],
        ));
  }

  Widget renderEmptyUI() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(Assets.launchBackground),
    );
  }
}
