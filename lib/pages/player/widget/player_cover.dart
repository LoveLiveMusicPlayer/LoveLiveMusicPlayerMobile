import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_info.dart';

import '../../../modules/ext.dart';
import '../../main/logic.dart';

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
      child: Column(
        children: [
          SizedBox(height: 24.h),

          /// 封面
          GetBuilder<MainLogic>(
            builder: (logic) {
              return showImg(logic.state.playingMusic.cover,
                  radius: 50, width: 300, height: 300);
            },
          ),

          /// 信息
          SizedBox(height: 20.h),
          PlayerInfo(),
        ],
      ),
    );
  }
}
