import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/main/logic.dart';

class PlayerInfo extends StatelessWidget {

  var logic = Get.find<MainLogic>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          recentlyLrc(logic.playingMusic.value.preJPLrc),
          SizedBox(height: 8.h),
          recentlyLrc(logic.playingMusic.value.currentJPLrc, color: const Color(0xFF333333)),
          SizedBox(height: 8.h),
          recentlyLrc(logic.playingMusic.value.nextJPLrc)
        ],
      )),
    );
  }

  Widget recentlyLrc(String? text, {Color color = const Color(0xFF999999)}) {
    if (text == null) {
      return Text("", style: TextStyle(color: color, fontSize: 15.sp));
    }
    return Text(text, style: TextStyle(color: color, fontSize: 15.sp));
  }
}