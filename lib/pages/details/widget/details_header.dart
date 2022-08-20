import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';

class DetailsHeader extends StatelessWidget {
  final String title;
  Function()? onBack;

  DetailsHeader({Key? key, required this.title, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Get.theme.primaryColor,
        child: Column(children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 14.56.h),
          Stack(alignment: Alignment.center, children: [
            Row(children: [
              Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: materialButton(Icons.keyboard_arrow_left, () {
                    if (onBack == null) {
                      HomeController.to.state.isSelect.value = false;
                      SmartDialog.dismiss();
                      Get.back();
                    } else {
                      onBack!();
                    }
                  }, width: 32, height: 32, iconSize: 24, radius: 6))
            ]),
            ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Get.width - 120.w),
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Get.isDarkMode
                          ? Colors.white
                          : const Color(0xFF333333),
                    )))
          ])
        ]));
  }
}
