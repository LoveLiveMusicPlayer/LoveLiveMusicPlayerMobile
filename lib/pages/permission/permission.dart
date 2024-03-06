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
    final uriGithub =
        Uri.parse("https://github.com/zhushenwudi/LoveLiveMusicPlayerMobile");
    final uriUmeng = Uri.parse("https://www.umeng.com/page/policy");
    final uriShare = Uri.parse("https://www.mob.com/about/policy");
    final uri360 = Uri.parse("https://jiagu.360.cn/#/global/help/322");
    final textColor =
        Get.isDarkMode ? TextStyleMs.white_12 : TextStyleMs.black_12;
    return Scaffold(
        backgroundColor: Get.theme.primaryColor,
        appBar: AppBar(
          elevation: 0,
          title: Text('privacy_agreement'.tr),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            child: Column(
              children: [
                RichText(
                    text: TextSpan(
                      style: textColor,
                      children: [
                        TextSpan(text: 'privacy_detail1'.tr, style: textColor),
                        TextSpan(
                          text: 'privacy_umeng'.tr,
                          style: TextStyleMs.blue_12,
                          // 设置点击事件
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (await canLaunchUrl(uriUmeng)) {
                                await launchUrl(uriUmeng, mode: LaunchMode.inAppWebView);
                              }
                            },
                        ),
                        TextSpan(text: 'privacy_detail2'.tr, style: textColor),
                        TextSpan(
                          text: 'privacy_share'.tr,
                          style: TextStyleMs.blue_12,
                          // 设置点击事件
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (await canLaunchUrl(uriShare)) {
                                await launchUrl(uriShare, mode: LaunchMode.inAppWebView);
                              }
                            },
                        ),
                        TextSpan(text: 'privacy_detail3'.tr, style: textColor),
                        TextSpan(
                          text: 'privacy_360'.tr,
                          style: TextStyleMs.blue_12,
                          // 设置点击事件
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (await canLaunchUrl(uri360)) {
                                await launchUrl(uri360, mode: LaunchMode.inAppWebView);
                              }
                            },
                        ),
                        TextSpan(text: 'privacy_detail4'.tr, style: textColor),
                      ]
                    )),
                // Text('privacy_detail'.tr, style: textColor),
                SizedBox(height: 12.h),
                Center(
                  child: Text.rich(TextSpan(
                    text: 'github_url'.tr,
                    style: TextStyleMs.blue_12,
                    // 设置点击事件
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (await canLaunchUrl(uriGithub)) {
                          await launchUrl(uriGithub, mode: LaunchMode.inAppWebView);
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
