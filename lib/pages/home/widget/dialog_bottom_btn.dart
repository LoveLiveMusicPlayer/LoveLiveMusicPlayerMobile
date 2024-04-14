import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class DialogBottomBtn extends StatelessWidget {
  final List<BtnItem> list;

  const DialogBottomBtn({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 102.h,
      decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h)),
          boxShadow: [
            BoxShadow(
                color: Get.theme.primaryColor,
                blurRadius: 16.h,
                spreadRadius: 16.h)
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
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            touchIconByAsset(
              path: path,
              width: 21,
              height: 21,
              color: Get.isDarkMode ? ColorMs.colorD1E0F3 : ColorMs.color666666,
            ),
            SizedBox(height: 7.h),
            Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Get.isDarkMode
                    ? TextStyleMs.colorD1E0F3_15
                    : TextStyleMs.lightBlack_15),
            SizedBox(
              height: 20.h,
            )
          ],
        ),
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
