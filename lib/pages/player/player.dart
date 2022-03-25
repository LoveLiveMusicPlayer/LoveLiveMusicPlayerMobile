import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_info.dart';
import 'package:lovelivemusicplayer/pages/test/logic.dart';
import '../../modules/ext.dart';

class Player extends StatefulWidget {
  final Function onTap;

  Player({required this.onTap});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final bottomHeight = 280.0;
  var logic = Get.find<TestLogic>();

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
                      SizedBox(height: MediaQuery.of(context).padding.top),

                      /// 头部
                      PlayerHeader(onTap: widget.onTap),
                      SizedBox(height: 20.h),

                      /// 封面
                      Obx(() => cover(
                          logic.musicList.value, logic.currentIndex.value)),

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

  Widget cover(List<Music> musicList, int index) {
    if (musicList.isEmpty || musicList[index].cover == null) {
      return showImg("assets/thumb/XVztg3oXmX4.jpg",
          radius: 50, width: 300.w, height: 300.h);
    }
    return showImg(musicList[index].cover!,
        radius: 50, width: 300.w, height: 300.h);
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
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              getProgressText(logic.musicList.value, logic.currentIndex.value),
              getProgressText(logic.musicList.value, logic.currentIndex.value)
            ],
          )),
    );
  }

  Widget getProgressText(List<Music> musicList, int index) {
    if (musicList.isEmpty || musicList[index].time == null) {
      return Text(
        "00:00",
        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
      );
    }
    return Text(
      musicList[index].time!,
      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
    );
  }

  Widget playButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          materialButton(Icons.skip_previous, () => {},
              width: 60, height: 60, radius: 40),
          materialButton(Icons.play_arrow, () => {},
              width: 80, height: 80, radius: 40, iconSize: 50),
          materialButton(Icons.skip_next, () => {},
              width: 60, height: 60, radius: 40),
        ],
      ),
    );
  }
}
