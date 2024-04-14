import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class TwoButtonDialog extends StatelessWidget {
  String _imgAsset = "";
  String? _title;
  String? _msg;
  bool _isShowTitle = true;
  bool _isShowMsg = true;
  bool _isShowImg = true;
  Callback? _onBackListener;
  Callback? _onConfirmListener;

  TwoButtonDialog({
    super.key,
    String imgAsset = Assets.mainIcErr,
    String? title,
    String? msg,
    bool isShowTitle = true,
    bool isShowMsg = true,
    bool isShowImg = true,
    Callback? onBackListener,
    Callback? onConfirmListener,
  }) {
    _imgAsset = imgAsset;
    _title = title;
    _msg = msg;
    _isShowTitle = isShowTitle;
    _isShowMsg = isShowMsg;
    _isShowImg = isShowImg;
    _onBackListener = onBackListener;
    _onConfirmListener = onConfirmListener;
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
          SizedBox(
            height: 28.h,
          ),
          Visibility(
              visible: _isShowImg,
              child: Image.asset(
                _imgAsset,
                width: 78.r,
                height: 78.r,
              )),
          SizedBox(
            height: 12.w,
          ),
          Visibility(
            visible: _isShowTitle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(_title ?? 'title'.tr,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Get.isDarkMode
                      ? TextStyleMs.white_18
                      : TextStyleMs.black_18),
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Visibility(
            visible: _isShowMsg,
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(_msg ?? 'message'.tr,
                    style: TextStyleMs.gray_14, textAlign: TextAlign.center)),
          ),
          SizedBox(
            height: 8.h,
          ),
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
                        _onBackListener?.call();
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
                        _onConfirmListener?.call();
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
}

typedef Callback = Function();
