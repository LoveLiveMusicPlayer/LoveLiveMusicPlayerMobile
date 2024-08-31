import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class TextFieldDialog extends StatefulWidget {
  final String? title;
  final String? hint;
  final int? maxLength;
  final List<TextInputFormatter>? formatter;
  final Function()? onBack;
  final Function(String str)? onConfirm;
  final TextEditingController? controller;

  const TextFieldDialog(
      {super.key,
      this.title,
      this.hint,
      this.formatter,
      this.onBack,
      this.controller,
      this.onConfirm,
      this.maxLength});

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  late final controller = widget.controller ?? TextEditingController();
  String text = "";
  late int maxLength = widget.maxLength ?? 20;

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
                inputFormatters: widget.formatter ?? [],
                decoration: InputDecoration(
                    isCollapsed: false,
                    labelText: widget.hint ?? 'hint'.tr,
                    labelStyle: TextStyle(fontSize: 14.h),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
                    counterStyle: TextStyle(fontSize: 10.h),
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
                  text = str.substring(0, min(len, maxLength));

                  controller.value = TextEditingValue(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length));
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
                        widget.onBack?.call();
                        SmartDialog.dismiss();
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
                        widget.onConfirm?.call(text);
                        SmartDialog.dismiss();
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
