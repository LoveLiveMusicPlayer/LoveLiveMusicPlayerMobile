import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class PlayerHeader extends StatelessWidget {
  final GestureTapCallback onCloseTap;
  final Function() onMoreTap;

  const PlayerHeader(
      {Key? key, required this.onCloseTap, required this.onMoreTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 44.h,
        width: double.infinity,
        child: Row(
          children: <Widget>[
            /// 折叠向下箭头
            materialButton(Icons.keyboard_arrow_down, onCloseTap,
                width: 32,
                height: 32,
                iconSize: 20,
                radius: 6,
                iconColor: PlayerLogic.to.hasSkin.value ? Colors.white : null,
                bgColor: PlayerLogic.to.hasSkin.value
                    ? const Color(0xFF1E2328)
                    : null,
                outerColor: PlayerLogic.to.hasSkin.value ? Colors.black : null),

            /// 曲名 + 歌手
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  PlayerLogic.to.playingMusic.value.musicName ?? "暂无歌曲",
                  overflow: TextOverflow.ellipsis,
                  style: PlayerLogic.to.hasSkin.value || Get.isDarkMode
                      ? TextStyleMs.whiteBold_15
                      : TextStyleMs.blackBold_15,
                  maxLines: 1,
                ),
                Text(
                  PlayerLogic.to.playingMusic.value.artist ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: PlayerLogic.to.hasSkin.value
                          ? const Color(0xffdfdfdf)
                          : const Color(0xFF999999),
                      fontSize: 12.sp),
                  maxLines: 1,
                )
              ],
            )),

            /// 更多功能
            materialButton(Icons.more_horiz, onMoreTap,
                width: 32,
                height: 32,
                iconSize: 18,
                radius: 6,
                iconColor: PlayerLogic.to.hasSkin.value ? Colors.white : null,
                bgColor: PlayerLogic.to.hasSkin.value
                    ? const Color(0xFF1E2328)
                    : null,
                outerColor: PlayerLogic.to.hasSkin.value ? Colors.black : null),
          ],
        ),
      ),
    );
  }
}
