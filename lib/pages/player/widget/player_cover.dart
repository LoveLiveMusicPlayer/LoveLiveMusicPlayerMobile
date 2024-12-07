import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_info.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class Cover extends StatefulWidget {
  final GestureTapCallback onTap;

  const Cover({super.key, required this.onTap});

  @override
  State<Cover> createState() => _CoverState();
}

class _CoverState extends State<Cover> {
  @override
  Widget build(BuildContext context) {
    Music? currentMusic = PlayerLogic.to.playingMusic.value;
    final imagePath = SDUtils.getImgPathFromMusic(currentMusic);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.transparent,
        height: 400.h,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
                visible: SDUtils.allowEULA, child: SizedBox(height: 18.h)),
            SizedBox(
                width: 273.h,
                height: 273.h,
                child: Stack(
                  children: [
                    /// 封面
                    showImg(imagePath, 273, 273,
                        radius: 24, onTap: widget.onTap),
                    renderBlackFilter()
                  ],
                )),
            Visibility(
                visible: SDUtils.allowEULA,
                child: const Expanded(
                  child: PlayerInfo(),
                ))
          ],
        ),
      ),
    );
  }

  Widget renderBlackFilter() {
    if (Get.isDarkMode) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(24.h),
          child: Container(
            color: Colors.black.withOpacity(0.2),
          ));
    } else {
      return Container();
    }
  }
}
