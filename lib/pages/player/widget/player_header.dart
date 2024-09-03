import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class PlayerHeader extends StatelessWidget {
  final GestureTapCallback onCloseTap;
  final Function() onMoreTap;
  final Color btnColor;

  const PlayerHeader(
      {super.key,
      required this.onCloseTap,
      required this.onMoreTap,
      required this.btnColor});

  @override
  Widget build(BuildContext context) {
    final hasSkin = GlobalLogic.to.hasSkin.value;
    final iconColor = hasSkin ? Colors.white : null;
    final bgColor = hasSkin ? btnColor : null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 44.h,
        width: double.infinity,
        child: Row(
          children: <Widget>[
            /// 折叠向下箭头
            neumorphicButton(
              Icons.keyboard_arrow_down,
              onCloseTap,
              iconSize: 20,
              iconColor: iconColor,
              shadowColor: bgColor,
              bgColor: bgColor,
            ),

            /// 曲名 + 歌手
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  PlayerLogic.to.playingMusic.value.musicName ?? 'no_songs'.tr,
                  overflow: TextOverflow.ellipsis,
                  style: hasSkin || Get.isDarkMode
                      ? TextStyleMs.whiteBold_15
                      : TextStyleMs.blackBold_15,
                  maxLines: 1,
                ),
                Text(
                  PlayerLogic.to.playingMusic.value.artist ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: hasSkin
                      ? TextStyleMs.colorDFDFDF_12
                      : TextStyleMs.gray_12,
                  maxLines: 1,
                )
              ],
            )),

            /// 更多功能
            neumorphicButton(
              Icons.more_horiz,
              onMoreTap,
              iconSize: 18,
              shadowColor: bgColor,
              iconColor: iconColor,
              bgColor: bgColor,
            )
          ],
        ),
      ),
    );
  }
}
