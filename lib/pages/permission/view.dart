import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/permission/logic.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class PermissionPage extends GetView<PermissionLogic> {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('privacy_agreement'.tr, style: TextStyleMs.white_18),
          backgroundColor:
              Get.isDarkMode ? ColorMs.colorNightPrimary : ColorMs.color28B3F7,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            child: Column(children: body()),
          ),
        ));
  }

  List<Widget> body() {
    final textColor =
        Get.isDarkMode ? TextStyleMs.white_12 : TextStyleMs.black_12;
    return [
      RichText(
          text: TextSpan(style: textColor, children: [
        TextSpan(text: 'privacy_detail1'.tr, style: textColor),
        urlTextSpan('privacy_umeng'.tr, controller.uriUmeng),
        TextSpan(text: 'privacy_detail2'.tr, style: textColor),
        urlTextSpan('privacy_share'.tr, controller.uriShare),
        TextSpan(text: 'privacy_detail3'.tr, style: textColor),
        urlTextSpan('privacy_360'.tr, controller.uri360),
        TextSpan(text: 'privacy_detail4'.tr, style: textColor),
      ])),
      SizedBox(height: 12.h),
      Center(
        child: Text.rich(urlTextSpan('github_url'.tr, controller.uriGithub)),
      ),
      SizedBox(height: Platform.isAndroid ? 12.h : 0)
    ];
  }

  TextSpan urlTextSpan(String text, Uri uri) {
    return TextSpan(
      text: text,
      style: TextStyleMs.blue_12,
      // 设置点击事件
      recognizer: TapGestureRecognizer()
        ..onTap = () => controller.launchWeb(uri),
    );
  }
}
