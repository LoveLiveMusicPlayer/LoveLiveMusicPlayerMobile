import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_info.dart';
import '../../modules/ext.dart';
import '../main/logic.dart';

class Player extends StatefulWidget {
  final GestureTapCallback onTap;

  Player({required this.onTap});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final bottomHeight = 280.0;
  var logic = Get.find<MainLogic>();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: <Widget>[
            coverBg(),
            Column(
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().screenHeight - bottomHeight,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery
                          .of(context)
                          .padding
                          .top),

                      /// 头部
                      PlayerHeader(onTap: widget.onTap),
                      SizedBox(height: 20.h),

                      /// 封面
                      GetBuilder<MainLogic>(
                        builder: (logic) {
                          return showImg(logic.state.playingMusic.cover, radius: 50, width: 300.w, height: 300.h);
                        },
                      ),

                      /// 信息
                      SizedBox(height: 20.h),
                      PlayerInfo(),
                    ],
                  ),
                ),
                SizedBox(
                  // color: Colors.red,
                  height: bottomHeight,
                  child: Column(
                    children: <Widget>[

                      /// 功能栏
                      funcButton(),
                      SizedBox(height: 34.h),

                      /// 滑动条
                      slider(),

                      /// 用时
                      progress(),

                      /// 播放器控制组件
                      playButton(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget funcButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          materialButton(Icons.favorite, () => {},
              width: 32,
              height: 32,
              radius: 6,
              iconColor: Colors.pinkAccent,
              iconSize: 15),
          materialButton(Icons.queue_music, () => {},
              width: 32,
              height: 32,
              radius: 6,
              iconColor: const Color(0xFF999999),
              iconSize: 15),
        ],
      ),
    );
  }

  Widget slider() {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(),
      ),
      child: Slider(
        inactiveColor: const Color(0xFFCCDDF1).withOpacity(0.6),
        activeColor: const Color(0xFFCCDDF1).withOpacity(0.6),
        thumbColor: const Color(0xFFF2F8FF),
        value: 10.5,
        min: 0.0,
        max: 100.0,
        onChanged: (double value) {},
      ),
    );
  }

  Widget progress() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GetBuilder<MainLogic>(builder: (logic) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              logic.state.playingMusic.playedTime ?? "00:00",
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
            ),
            Text(
              logic.state.playingMusic.totalTime ?? "00:00",
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
            )
          ],
        );
      }),
    );
  }

  Widget playButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          materialButton(
              Icons.skip_previous, () => logic.playPrevMusic(),
              width: 60, height: 60, radius: 40),
          materialButton(Icons.play_arrow, () => logic.togglePlay(),
              width: 80, height: 80, radius: 40, iconSize: 50),
          materialButton(
              Icons.skip_next, () => logic.playNextMusic(),
              width: 60, height: 60, radius: 40),
        ],
      ),
    );
  }
}
