import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../modules/ext.dart';

class DetailsHeader extends StatelessWidget {
  String title;
  DetailsHeader({Key? key,this.title = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F8FF),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            /// 折叠向下箭头
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16.h, top: 18.h),
                child: materialButton(Icons.keyboard_arrow_left, () {
                  Get.back();
                },
                    width: 32,
                    height: 32,
                    iconSize: 24,
                    radius: 6,
                    iconColor: const Color(0xFF333333)),
              ),
            ),
            SizedBox(
              width: 200.h,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp,
                    color: const Color(0xff333333),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
