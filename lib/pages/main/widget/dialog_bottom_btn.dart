import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class DialogBottomBtn extends StatelessWidget {
  List<BtnItem> list;

  DialogBottomBtn({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 102.h,
      decoration: BoxDecoration(
          color: const Color(0xFFF2F8FF),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h)),
          boxShadow: [
            BoxShadow(color: Colors.white, blurRadius: 16.h, spreadRadius: 16.h)
          ]),
      child: Row(
        children: getListWidget(),
      ),
    );
  }

  List<Widget> getListWidget() {
    List<Widget> widgetList = [];
    for (var element in list) {
      widgetList.add(_buildItem(element.imgPath, element.title, element.onTap));
    }
    return widgetList;
  }

  Widget _buildItem(String path, String title, GestureTapCallback onTap) {
    return Expanded(
        child: GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            path,
            width: 21.h,
            height: 21.h,
            color: const Color(0xff666666),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: const Color(0xff666666), fontSize: 15.sp),
          ),
          SizedBox(height: 20.h,)
        ],
      ),
    ));
  }
}

class BtnItem {
  String imgPath;
  String title;
  GestureTapCallback onTap;

  BtnItem({required this.imgPath, required this.title, required this.onTap});
}
