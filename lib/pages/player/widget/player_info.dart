import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

class PlayerInfo extends StatelessWidget {
  const PlayerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final playingColor = GlobalLogic.to.hasSkin.value || Get.isDarkMode
            ? Colors.white
            : Colors.black;
        final otherColor = GlobalLogic.to.hasSkin.value
            ? ColorMs.colorDFDFDF.withOpacity(0.4)
            : ColorMs.color999999;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            recentlyLrc(PlayerLogic.to.playingJPLrc["pre"], color: otherColor),
            SizedBox(height: 10.h),
            recentlyLrc(PlayerLogic.to.playingJPLrc["current"],
                color: playingColor, fontWeight: FontWeight.bold),
            SizedBox(height: 10.h),
            recentlyLrc(PlayerLogic.to.playingJPLrc["next"], color: otherColor)
          ],
        );
      }),
    );
  }

  Widget recentlyLrc(String? text,
      {Color? color, FontWeight fontWeight = FontWeight.normal}) {
    if (text == null) {
      return Text("", style: TextStyle(color: color, fontSize: 15.h));
    }
    return Text(text,
        style: TextStyle(
            color: color ??
                (GlobalLogic.to.hasSkin.value || Get.isDarkMode
                    ? ColorMs.colorDFDFDF
                    : ColorMs.colorB7BCC1),
            fontSize: 15.sp,
            fontWeight: fontWeight),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }
}
