import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/sd/logic.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class SDCard extends GetView<SDCardLogic> {
  const SDCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('storage_settings'.tr, style: TextStyleMs.white_18),
          backgroundColor:
              Get.isDarkMode ? ColorMs.colorNightPrimary : ColorMs.color28B3F7,
        ),
        body: SafeArea(
            child: Column(
          children: [
            Container(
              color: Get.isDarkMode
                  ? ColorMs.colorNightPrimary
                  : ColorMs.color28B3F7,
              width: double.infinity,
              height: 50.h,
              child: Center(
                  child: Text(
                'change_storage_warning'.tr,
                style: Get.isDarkMode
                    ? TextStyleMs.white_15_500
                    : TextStyleMs.black_15_500,
                textAlign: TextAlign.center,
              )),
            ),
            Obx(() {
              return Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.h,
                      crossAxisSpacing: 20.w,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.w, vertical: 10.h),
                      children: renderItem()));
            }),
          ],
        )));
  }

  List<Widget> renderItem() {
    final widgets = <Widget>[];
    for (var sdcard in controller.sdList) {
      widgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            neumorphicButton(
                Assets.drawerDrawerSd, () => controller.click(sdcard),
                width: 80.h,
                height: 80.h,
                iconColor: Colors.pinkAccent,
                shadowColor: sdcard.choose ? Colors.amber : null,
                bgColor: Get.isDarkMode
                    ? ColorMs.colorNightPrimary
                    : ColorMs.color28B3F7,
                margin: EdgeInsets.all(10.r),
                padding: EdgeInsets.all(20.r)),
            Text(sdcard.name,
                style: sdcard.choose
                    ? TextStyleMs.white_15_500
                        .merge(TextStyle(color: Colors.amber))
                    : Get.isDarkMode
                        ? TextStyleMs.white_15_500
                        : TextStyleMs.black_15_500)
          ],
        ),
      ));
    }
    return widgets;
  }
}
