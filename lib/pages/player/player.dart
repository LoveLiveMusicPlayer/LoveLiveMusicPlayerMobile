import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_cover.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_lyric.dart';

import '../../modules/ext.dart';
import '../../network/http_request.dart';
import '../main/logic.dart';

class Player extends StatefulWidget {
  final GestureTapCallback onTap;
  var isCover = true.obs;

  Player({required this.onTap});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  var logic = Get.find<MainLogic>();

  @override
  void initState() {
    super.initState();
  }

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
                top(),
                bottom(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget top() {
    return SizedBox(
      height: 600.h,
      child: Column(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top + 16.h),

          /// 头部
          PlayerHeader(onTap: widget.onTap),

          /// 中间可切换的界面
          Obx(() => stackBody()),

          SizedBox(height: 30.h),

          /// 功能栏
          Obx(() => funcButton())
        ],
      ),
    );
  }

  Widget bottom() {
    return Column(
      children: <Widget>[
        /// 滑动条
        slider(),

        /// 用时
        progress(),

        SizedBox(height: 24.h),

        /// 播放器控制组件
        playButton(),
      ],
    );
  }

  Widget stackBody() {
    if (widget.isCover.value) {
      return Cover(onTap: () {
        widget.isCover.value = false;
      });
    } else {
      return Lyric(onTap: () {
        widget.isCover.value = true;
      });
    }
  }

  Widget funcButton() {
    if (!widget.isCover.value) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GetBuilder<MainLogic>(builder: (_) {
              return materialButton(
                  logic.state.playingMusic.isLove
                      ? Icons.favorite
                      : "assets/player/play_love.svg",
                  () => logic.toggleLove(),
                  width: 32,
                  height: 32,
                  radius: 6,
                  iconColor: Colors.pinkAccent,
                  iconSize: 15);
            })
          ]));
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GetBuilder<MainLogic>(builder: (logic) {
            return materialButton(
                logic.state.playingMusic.isLove
                    ? Icons.favorite
                    : "assets/player/play_love.svg",
                () => logic.toggleLove(),
                width: 32,
                height: 32,
                radius: 6,
                iconColor: Colors.pinkAccent,
                iconSize: 15);
          }),
          materialButton(Icons.add, () => {},
              width: 32,
              height: 32,
              radius: 6,
              iconColor: const Color(0xFF999999),
              iconSize: 20),
        ],
      ),
    );
  }

  Widget slider() {
    return SliderTheme(
      data: const SliderThemeData(
          trackHeight: 4, thumbShape: RoundSliderThumbShape()),
      child: Slider(
        inactiveColor: const Color(0xFFCCDDF1).withOpacity(0.6),
        activeColor: const Color(0xFFCCDDF1).withOpacity(0.6),
        thumbColor: Theme.of(Get.context!).primaryColor,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          materialButton("assets/player/play_shuffle.svg", () => {},
              width: 32,
              height: 32,
              radius: 6,
              iconSize: 15,
              iconColor: const Color(0xFF333333)),
          materialButton("assets/player/play_prev.svg",
              () => logic.playPrevOrNextMusic(true),
              width: 60, height: 60, radius: 40, iconSize: 16),
          GetBuilder<MainLogic>(builder: (logic) {
            return materialButton(
                logic.state.isPlaying
                    ? "assets/player/play_pause.svg"
                    : "assets/player/play_play.svg",
                () => logic.togglePlay(),
                width: 80,
                height: 80,
                radius: 40,
                iconSize: 26);
          }),
          materialButton("assets/player/play_next.svg",
              () => logic.playPrevOrNextMusic(false),
              width: 60, height: 60, radius: 40, iconSize: 16),
          materialButton("assets/player/play_playlist.svg", () => {},
              width: 32,
              height: 32,
              radius: 6,
              iconSize: 15,
              iconColor: const Color(0xFF333333)),
        ],
      ),
    );
  }

  /// 覆盖背景
  Widget coverBg({Color color = const Color(0xFFF2F8FF), double radius = 34}) {
    return Container(
      height: ScreenUtil().screenHeight,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(34)),
      // child: Stack(
      //   children: buildReaderBackground(),
      // ),
    );
  }

// List<Widget> buildReaderBackground() {
//   return [
//     Positioned.fill(
//         child: GetBuilder<MainLogic>(builder: (logic) {
//           return showImg(logic.state.playingMusic.cover);
//         })
//     ),
//     Positioned.fill(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
//         child: Container(
//           color: Colors.black.withOpacity(0.4),
//         ),
//       ),
//     )
//   ];
// }
}
