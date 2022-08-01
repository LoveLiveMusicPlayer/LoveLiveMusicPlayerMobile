import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_info.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class Cover extends StatefulWidget {
  final GestureTapCallback onTap;

  const Cover({Key? key, required this.onTap}) : super(key: key);

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
        height: 400.h,
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 18.h),

            /// 封面
            Obx(
              () {
                return showImg(
                  SDUtils.getImgPath(
                      PlayerLogic.to.playingMusic.value.coverPath ?? ""),
                  273,
                  273,
                  radius: 24,
                );
              },
            ),

            /// 信息
            SizedBox(height: 18.h),
            const PlayerInfo(),
          ],
        ),
      ),
    );
  }
}
