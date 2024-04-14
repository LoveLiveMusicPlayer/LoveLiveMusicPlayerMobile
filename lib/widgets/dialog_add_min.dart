import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

const tenMin = 10;
const twentyMin = 30;
const maxMin = 180;

class AddMinDialog extends StatefulWidget {
  String? _title;
  Callback? _onBackListener;
  Callback? _onConfirmListener;
  int? _initTimer;

  AddMinDialog({
    super.key,
    String? title,
    Callback? onBackListener,
    Callback? onConfirmListener,
    int? initTimer = 0,
  }) {
    _title = title;
    _initTimer = initTimer;
    _onBackListener = onBackListener;
    _onConfirmListener = onConfirmListener;
  }

  @override
  State<AddMinDialog> createState() => _AddMinDialogState();
}

class _AddMinDialogState extends State<AddMinDialog> {
  late int _counter;
  late String _endTime;

  @override
  void initState() {
    _counter = widget._initTimer ?? 0;
    _endTime = calcTime(_counter);
    super.initState();
  }

  String calcTime(int min) {
    DateTime futureTime = DateTime.now().add(Duration(minutes: min));
    final hour = futureTime.hour.toString().padLeft(2, '0');
    final minute = futureTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final width = min(0.4 * Get.height, 0.8 * Get.width);
    return Center(
        child: Container(
      width: width,
      decoration: BoxDecoration(
          color: Get.isDarkMode ? Get.theme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 28.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(widget._title ?? 'title'.tr,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Get.isDarkMode
                    ? TextStyleMs.white_18
                    : TextStyleMs.black_18),
          ),
          SizedBox(height: 18.h),
          Text(_counter.toString(), style: TextStyleMs.black_15),
          Text("${'end_time'.tr}$_endTime",
              style: const TextStyle(color: Colors.red)),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  renderMinButton(twentyMin),
                  SizedBox(width: 5.w),
                  renderMinButton(tenMin),
                  SizedBox(width: 5.w),
                  renderAddButton(tenMin),
                  SizedBox(width: 5.w),
                  renderAddButton(twentyMin),
                ],
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.grey : ColorMs.colorEDF5FF,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.r),
                      )),
                  child: TextButton(
                      onPressed: () {
                        SmartDialog.dismiss();
                        widget._onBackListener?.call();
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
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? ColorMs.color0093DF
                          : ColorMs.color28B3F7,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16.r))),
                  child: TextButton(
                      onPressed: () {
                        SmartDialog.dismiss();
                        widget._onConfirmListener?.call(_counter);
                      },
                      child: Text(
                        'confirm'.tr,
                        style: TextStyleMs.white_16,
                      )),
                ),
              )
            ],
          )
        ],
      ),
    ));
  }

  Widget renderAddButton(int offset) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Get.isDarkMode ? ColorMs.color0093DF : ColorMs.color28B3F7,
          minimumSize: Size(0.w, 30.h),
        ),
        onPressed: _counter < maxMin
            ? () {
                final count =
                    _counter + offset > maxMin ? maxMin : _counter + offset;
                setState(() {
                  _counter = count;
                  _endTime = calcTime(count);
                });
              }
            : null,
        child: Text('+$offset'));
  }

  Widget renderMinButton(int offset) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor:
              Get.isDarkMode ? ColorMs.color0093DF : ColorMs.color28B3F7,
          minimumSize: Size(0.w, 30.h)),
      onPressed: _counter > 0
          ? () {
              final count = _counter - offset < 0 ? 0 : _counter - offset;
              setState(() {
                _counter = count;
                _endTime = calcTime(count);
              });
            }
          : null,
      child: Text('-$offset'),
    );
  }
}

typedef Callback = Function([int? number]);
