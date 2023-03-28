import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class OneButtonDialog extends StatelessWidget {
  String _imgAsset = "";
  String _title = "";
  String _msg = "";
  bool _isShowTitle = true;
  bool _isShowMsg = true;
  bool _isShowImg = true;
  Callback? _onBackListener;

  OneButtonDialog(
      {Key? key,
      String imgAsset = Assets.logoLogo,
      String? title,
      String? msg,
      bool isShowTitle = true,
      bool isShowMsg = true,
      bool isShowImg = true,
      Callback? onBackListener})
      : super(key: key) {
    _imgAsset = imgAsset;
    _title = title ?? "标题";
    _msg = msg ?? "网络异常!";
    _isShowTitle = isShowTitle;
    _isShowMsg = isShowMsg;
    _isShowImg = isShowImg;
    _onBackListener = onBackListener;
  }

  @override
  Widget build(BuildContext context) {
    final width = min(0.4 * Get.height, 0.8 * Get.width);
    return Center(
        child: Container(
      width: width,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
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
            height: 12.h,
          ),
          Visibility(
            visible: _isShowTitle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(_title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleMs.black_18),
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Visibility(
            visible: _isShowMsg,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  _msg,
                  style: TextStyleMs.gray_14,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )),
          ),
          SizedBox(
            height: 8.h,
          ),
          Container(
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
                color: ColorMs.color28B3F7,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r))),
            child: TextButton(
                onPressed: () {
                  SmartDialog.compatible.dismiss();
                  if (_onBackListener != null) _onBackListener!();
                },
                child: Text(
                  'confirm'.tr,
                  style: TextStyleMs.white_16,
                )),
          )
        ],
      ),
    ));
  }
}

typedef Callback = Function();
