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
    return Center(
        child: Container(
            width: 300.w,
            decoration: BoxDecoration(
                color: Get.isDarkMode ? Get.theme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16.r)),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 12.h),
                  renderText('choose_your_clean_data'.tr, 18.sp),
                  SizedBox(height: 24.h),
                  renderButton('remove_songs_data'.tr, deleteMusicData),
                  SizedBox(height: 24.h),
                  renderButton('remove_user_data'.tr, deleteUserData,
                      hasAfter: false),
                  SizedBox(height: 24.h),
                  renderText('explain_songs_data'.tr, 12.sp),
                  SizedBox(height: 3.h),
                  renderText('explain_user_data'.tr, 12.sp),
                  SizedBox(height: 12.h),
                ])));
  }

  Widget renderButton(String text, Callback onBackListener,
      {bool hasAfter = true}) {
    return Container(
      width: 200.w,
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
            style: TextStyleMs.white_16,
          )),
    );
  }

  Widget renderText(String text, double? fontSize) {
    final color = Get.isDarkMode ? Colors.white : Colors.black;
    return Text(text, style: TextStyle(color: color, fontSize: fontSize));
  }
}

typedef Callback = Function();
