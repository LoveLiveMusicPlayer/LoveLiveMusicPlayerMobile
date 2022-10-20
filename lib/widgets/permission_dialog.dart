import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class PermissionDialog extends StatelessWidget {
  final mainMsg =
      "欢迎使用LoveLiveMusicPlayer!\n\n我们将通过《用户协议及隐私政策》帮助您了解本软件为您提供的服务，及收集、处理您个人数据的方式。\n点击【同意并继续】按钮代表您已同意。";
  final clickFrontMsg = "查看完整版";
  final Callback? readPermission;
  final Callback? confirm;

  const PermissionDialog({Key? key, this.readPermission, this.confirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleColor =
        Get.isDarkMode ? TextStyleMs.white_18_bold : TextStyleMs.black_18_bold;
    final textColor =
        Get.isDarkMode ? TextStyleMs.white_14 : TextStyleMs.black_14;
    final miniTextColor =
        Get.isDarkMode ? TextStyleMs.white_12 : TextStyleMs.black_12;
    return Center(
      child: Container(
          width: 300.w,
          padding: EdgeInsets.only(left: 16.w, right: 16.w),
          decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: BorderRadius.circular(16.w)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 26.h),
              Text("隐私保护政策", style: titleColor),
              SizedBox(height: 16.h),
              Text(mainMsg, style: textColor),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Text(clickFrontMsg, style: miniTextColor),
                  Text.rich(
                    TextSpan(
                      text: "《用户协议及隐私政策》",
                      style: TextStyleMs.blue_12,
                      // 设置点击事件
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          SmartDialog.compatible.dismiss();
                          if (readPermission != null) readPermission!();
                        },
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: const Color(0xFF28B3F7),
                    borderRadius: BorderRadius.all(Radius.circular(20.w))),
                child: TextButton(
                    onPressed: () {
                      SmartDialog.compatible.dismiss();
                      if (confirm != null) confirm!();
                    },
                    child: Text(
                      "同意并继续",
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    )),
              ),
              TextButton(
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.resolveWith((states) {
                    return Colors.transparent;
                  })),
                  onPressed: () {
                    if (Platform.isIOS) {
                      exit(0);
                    } else {
                      SystemNavigator.pop();
                    }
                  },
                  child: Text("不同意", style: miniTextColor)
              ),
            ],
          )),
    );
  }
}

typedef Callback = Function();
