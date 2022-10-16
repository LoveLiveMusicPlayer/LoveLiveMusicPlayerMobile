import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_info.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class Cover extends StatefulWidget {
  final GestureTapCallback onTap;

  const Cover({Key? key, required this.onTap}) : super(key: key);

  @override
  State<Cover> createState() => _CoverState();
}

class _CoverState extends State<Cover> {
  @override
  Widget build(BuildContext context) {
    Music? currentMusic = PlayerLogic.to.playingMusic.value;
    return InkWell(
      splashColor: Colors.red,
      onTap: widget.onTap,
      child: SizedBox(
        height: 400.h,
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 18.h),

            SizedBox(
                width: 273.h,
                height: 273.h,
                child: Stack(
                  children: [
                    /// 封面
                    showImg(
                        SDUtils.getImgPath(
                            fileName:
                                "${currentMusic.baseUrl}${currentMusic.coverPath}"),
                        273,
                        273,
                        radius: 24,
                        shadowColor: GlobalLogic.to.hasSkin.value
                            ? GlobalLogic.to.iconColor.value.withAlpha(255)
                            : null),
                    renderBlackFilter()
                  ],
                )),

            /// 信息
            SizedBox(height: 18.h),
            const PlayerInfo()
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
