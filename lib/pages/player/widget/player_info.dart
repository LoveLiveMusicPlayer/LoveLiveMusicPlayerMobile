import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';

class PlayerInfo extends StatelessWidget {
  const PlayerInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            recentlyLrc(PlayerLogic.to.playingJPLrc["pre"]),
            SizedBox(height: 10.h),
            recentlyLrc(PlayerLogic.to.playingJPLrc["current"],
                color: PlayerLogic.to.hasSkin.value || Get.isDarkMode
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold),
            SizedBox(height: 10.h),
            recentlyLrc(PlayerLogic.to.playingJPLrc["next"])
          ],
        );
      }),
    );
  }

  Widget recentlyLrc(String? text,
      {Color? color, FontWeight fontWeight = FontWeight.normal}) {
    if (text == null) {
      return Text("", style: TextStyle(color: color, fontSize: 15.sp));
    }
    return Text(text,
        style: TextStyle(
            color: color ??
                (PlayerLogic.to.hasSkin.value || Get.isDarkMode
                    ? const Color(0xffdfdfdf)
                    : const Color(0xFFB7BCC1)),
            fontSize: 15.sp,
            fontWeight: fontWeight),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }
}
