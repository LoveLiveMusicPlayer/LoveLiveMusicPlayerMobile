import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class PermissionDialog extends StatelessWidget {
  final Callback? readPermission;
  final Callback? confirm;

  const PermissionDialog({Key? key, this.readPermission, this.confirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleColor =
        Get.isDarkMode ? TextStyleMs.whiteBold_18 : TextStyleMs.blackBold_18;
    final textColor =
        Get.isDarkMode ? TextStyleMs.white_14 : TextStyleMs.black_14;
    final miniTextColor =
        Get.isDarkMode ? TextStyleMs.white_12 : TextStyleMs.black_12;
    return Center(
      child: Container(
          width: min(0.4 * Get.height, 0.8 * Get.width),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 26.h),
              Text('privacy_policy'.tr, style: titleColor),
              SizedBox(height: 16.h),
              Text('permission_main_message'.tr, style: textColor),
              SizedBox(height: 18.h),
              RichText(
                softWrap: true,
                text: TextSpan(children: [
                  TextSpan(
                      text: 'permission_show_full'.tr, style: miniTextColor),
                  WidgetSpan(child: SizedBox(width: 4.w)),
                  TextSpan(
                    text: 'permission_external_link'.tr,
                    style: TextStyleMs.blue_12,
                    // 设置点击事件
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        SmartDialog.compatible.dismiss();
                        readPermission?.call();
                      },
                  )
                ]),
              ),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                height: 40.h,
                decoration: BoxDecoration(
                    color: ColorMs.color28B3F7,
                    borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: TextButton(
                    onPressed: () {
                      SmartDialog.compatible.dismiss();
                      confirm?.call();
                    },
                    child: Text(
                      'permission_agree'.tr,
                      style: TextStyleMs.white_16,
                    )),
              ),
              SizedBox(height: 6.h),
              SizedBox(
                height: 32.h,
                child: TextButton(
                    style: ButtonStyle(overlayColor:
                        MaterialStateProperty.resolveWith((states) {
                      return Colors.transparent;
                    })),
                    onPressed: () {
                      if (Platform.isIOS) {
                        exit(0);
                      } else {
                        SystemNavigator.pop();
                      }
                    },
                    child:
                        Text('permission_disagree'.tr, style: miniTextColor)),
              ),
            ],
          )),
    );
  }
}

typedef Callback = Function();
