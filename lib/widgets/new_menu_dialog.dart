import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class NewMenuDialog extends StatefulWidget {
  final String? title;
  final Function()? onBack;
  final Function(String str)? onConfirm;

  const NewMenuDialog({Key? key, this.title, this.onBack, this.onConfirm})
      : super(key: key);

  @override
  State<NewMenuDialog> createState() => _NewMenuDialogState();
}

class _NewMenuDialogState extends State<NewMenuDialog> {
  final controller = TextEditingController();
  String text = "";
  int maxLength = 20;

  @override
  Widget build(BuildContext context) {
    final width = min(0.4 * Get.height, 0.8 * Get.width);
    return Container(
      width: width,
      height: 230.h,
      decoration: BoxDecoration(
          color: Get.isDarkMode ? Get.theme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 26.h, bottom: 8.h),
            child: Text(widget.title ?? 'title'.tr,
                style: Get.isDarkMode
                    ? TextStyleMs.white_18
                    : TextStyleMs.black_18),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: TextField(
                controller: controller,
                cursorColor: Colors.blue,
                cursorHeight: 18.h,
                cursorRadius: Radius.circular(15.r),
                cursorWidth: 2,
                showCursor: true,
                obscureText: false,
                maxLength: maxLength,
                decoration: InputDecoration(
                    isCollapsed: false,
                    labelText: 'input_menu_name'.tr,
                    labelStyle: TextStyle(fontSize: 14.sp),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
                    counterStyle: TextStyle(fontSize: 10.sp),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red))),
                onChanged: (str) {
                  if (controller.value.isComposingRangeValid) {
                    // ios自带输入法bug修复
                    return;
                  }
                  final len = str.length;
                  if (len < maxLength) {
                    text = str.substring(0, len);
                  } else {
                    text = str.substring(0, maxLength);
                  }

                  controller.value = TextEditingValue(
                      text: text,
                      selection:
                      TextSelection.collapsed(offset: text.length));
                  setState(() {});
                },
                onSubmitted: (str) {
                  text = str;
                  setState(() {});
                },
                textInputAction: TextInputAction.done),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.grey : ColorMs.colorEDF5FF,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.r),
                      )),
                  child: TextButton(
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        }
                        SmartDialog.compatible.dismiss();
                      },
                      child: Text('cancel'.tr,
                          style: Get.isDarkMode
                              ? TextStyleMs.white_16
                              : TextStyleMs.gray_16)),
                ),
              ),
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? ColorMs.color0093DF
                          : ColorMs.color28B3F7,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16.r))),
                  child: TextButton(
                      onPressed: () {
                        if (widget.onConfirm != null) {
                          widget.onConfirm!(text);
                        }
                        SmartDialog.compatible.dismiss();
                      },
                      child: Text('confirm'.tr, style: TextStyleMs.white_16)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
