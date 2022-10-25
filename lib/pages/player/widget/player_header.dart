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
      {Key? key,
      required this.onCloseTap,
      required this.onMoreTap,
      required this.btnColor})
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
                hasShadow: !GlobalLogic.to.hasSkin.value,
                iconColor: GlobalLogic.to.hasSkin.value ? Colors.white : null,
                bgColor: GlobalLogic.to.hasSkin.value ? btnColor : null,
                outerColor: GlobalLogic.to.hasSkin.value ? btnColor : null),

            /// 曲名 + 歌手
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  PlayerLogic.to.playingMusic.value.musicName ?? 'no_songs'.tr,
                  overflow: TextOverflow.ellipsis,
                  style: GlobalLogic.to.hasSkin.value || Get.isDarkMode
                      ? TextStyleMs.whiteBold_15
                      : TextStyleMs.blackBold_15,
                  maxLines: 1,
                ),
                Text(
                  PlayerLogic.to.playingMusic.value.artist ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: GlobalLogic.to.hasSkin.value
                      ? TextStyleMs.colorDFDFDF_12
                      : TextStyleMs.gray_12,
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
                hasShadow: !GlobalLogic.to.hasSkin.value,
                iconColor: GlobalLogic.to.hasSkin.value ? Colors.white : null,
                bgColor: GlobalLogic.to.hasSkin.value ? btnColor : null,
                outerColor: GlobalLogic.to.hasSkin.value ? btnColor : null),
          ],
        ),
      ),
    );
  }
}
