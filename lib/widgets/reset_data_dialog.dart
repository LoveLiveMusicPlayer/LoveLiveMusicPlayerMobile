import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class ResetDataDialog extends StatelessWidget {
  final Callback deleteMusicData;
  final Callback deleteUserData;
  final Callback afterDelete;

  const ResetDataDialog(
      {Key? key,
      required this.deleteMusicData,
      required this.deleteUserData,
      required this.afterDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = min(0.4 * Get.height, 0.8 * Get.width);
    return Center(
        child: Container(
            width: width,
            decoration: BoxDecoration(
                color: Get.isDarkMode ? Get.theme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 12.h),
                    renderText('choose_your_clean_data'.tr, 18.h),
                    SizedBox(height: 24.h),
                    renderButton('remove_songs_data'.tr, deleteMusicData),
                    SizedBox(height: 24.h),
                    renderButton('remove_user_data'.tr, deleteUserData,
                        hasAfter: false),
                    SizedBox(height: 24.h),
                    renderText('explain_songs_data'.tr, 12.h),
                    SizedBox(height: 3.h),
                    renderText('explain_user_data'.tr, 12.h),
                    SizedBox(height: 12.h),
                  ]),
            )));
  }

  Widget renderButton(String text, Callback onBackListener,
      {bool hasAfter = true}) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Container(
        width: double.infinity,
        height: 44.h,
        decoration: BoxDecoration(
            color: ColorMs.color28B3F7,
            borderRadius: BorderRadius.circular(16.r)),
        child: TextButton(
            onPressed: () {
              SmartDialog.compatible.dismiss();
              SmartDialog.compatible
                  .showLoading(msg: 'resetting'.tr, backDismiss: false);
              onBackListener();
              if (hasAfter) {
                afterDelete();
              }
            },
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleMs.white_16,
            )),
      ),
    );
  }

  Widget renderText(String text, double? fontSize) {
    final color = Get.isDarkMode ? Colors.white : Colors.black;
    return Text(text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: fontSize));
  }
}

typedef Callback = Function();
