import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class Permission extends StatefulWidget {
  const Permission({Key? key}) : super(key: key);

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {

  @override
  void initState() {
    super.initState();
    AppUtils.uploadEvent("Permission");
  }

  @override
  Widget build(BuildContext context) {
    final uri =
        Uri.parse("https://github.com/zhushenwudi/LoveLiveMusicPlayerMobile");
    final textColor =
        Get.isDarkMode ? TextStyleMs.white_12 : TextStyleMs.black_12;
    return Scaffold(
        backgroundColor: Get.theme.primaryColor,
        appBar: AppBar(
          title: Text('privacy_agreement'.tr),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            child: Column(
              children: [
                Text('privacy_detail'.tr, style: textColor),
                Center(
                  child: Text.rich(TextSpan(
                    text: 'github_url'.tr,
                    style: TextStyleMs.blue_12,
                    // 设置点击事件
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.inAppWebView);
                        }
                      },
                  )),
                ),
                SizedBox(height: Platform.isAndroid ? 12.h : 0)
              ],
            ),
          ),
        ));
  }
}
