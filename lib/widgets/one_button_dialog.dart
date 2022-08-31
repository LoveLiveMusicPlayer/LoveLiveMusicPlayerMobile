import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';

class OneButtonDialog extends StatelessWidget {
  String _imgAsset = "";
  String _title = "";
  String _msg = "";
  bool _isShowTitle = true;
  bool _isShowMsg = true;
  Callback? _onBackListener;

  OneButtonDialog(
      {Key? key,
      String imgAsset = Assets.logoLogo,
      String title = "标题",
      String msg = "网络异常!",
      bool isShowTitle = true,
      bool isShowMsg = true,
      Callback? onBackListener})
      : super(key: key) {
    _imgAsset = imgAsset;
    _title = title;
    _msg = msg;
    _isShowTitle = isShowTitle;
    _isShowMsg = isShowMsg;
    _onBackListener = onBackListener;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: 303.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16.w)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 28.w,
          ),
          Image.asset(
            _imgAsset,
            width: 78.w,
            height: 78.w,
          ),
          SizedBox(
            height: 12.w,
          ),
          Visibility(
            visible: _isShowTitle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 18.sp, color: const Color(0xFF333333)),
              ),
            ),
          ),
          SizedBox(
            height: 8.w,
          ),
          Visibility(
            visible: _isShowMsg,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  _msg,
                  style: TextStyle(
                      color: const Color(0xFF999999), fontSize: 14.sp),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )),
          ),
          SizedBox(
            height: 28.w,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Color(0xFF28B3F7),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.w),
                    bottomRight: Radius.circular(16.w))),
            child: TextButton(
                onPressed: () {
                  SmartDialog.compatible.dismiss();
                  if (_onBackListener != null) _onBackListener!();
                },
                child: Text(
                  "确定",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                )),
          )
        ],
      ),
    ));
  }
}

typedef Callback = Function();
