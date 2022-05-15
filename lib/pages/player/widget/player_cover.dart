import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_info.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

import '../../../modules/ext.dart';

class Cover extends StatefulWidget {
  final GestureTapCallback onTap;

  Cover({required this.onTap});

  @override
  _CoverState createState() => _CoverState();
}

class _CoverState extends State<Cover> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.red,
      onTap: widget.onTap,
      child: SizedBox(
        height: 440.h,
        child: Column(
          children: [
            SizedBox(height: 24.h),

            /// 封面
            Obx(
              () {
                return showImg(
                    SDUtils.getImgPath(
                        PlayerLogic.to.playingMusic.value.coverPath ?? ""),
                    radius: 24,
                    width: 300,
                    height: 300);
              },
            ),

            /// 信息
            SizedBox(height: 26.h),
            const PlayerInfo(),
          ],
        ),
      ),
    );
  }
}
