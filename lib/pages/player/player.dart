import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/PlayMode.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_cover.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_lyric.dart';
import 'package:lovelivemusicplayer/pages/player/widget/seekbar.dart';
import '../../modules/ext.dart';

class Player extends StatefulWidget {
  final GestureTapCallback onTap;
  var isCover = true.obs;

  Player({required this.onTap});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {

  /// slider 正在被滑动
  var isTouch = false.obs;

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
      return Lyric(
          key: const Key("Lyric"),
          onTap: () {
            widget.isCover.value = true;
          });
    }
  }

  Widget funcButton() {
    if (!widget.isCover.value) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            materialButton(
                Icons.youtube_searched_for, () => PlayerLogic.to.getLrc(true),
                width: 32,
                height: 32,
                radius: 6,
                iconColor: const Color(0xFF333333),
                iconSize: 20),
            Obx(() {
              var icon;
              switch (PlayerLogic.to.lrcType.value) {
                case 0:
                  icon = "assets/player/play_jp.svg";
                  break;
                case 1:
                  icon = "assets/player/play_zh.svg";
                  break;
                case 2:
                  icon = "assets/player/play_roma.svg";
                  break;
              }
              return materialButton(
                  icon, () => PlayerLogic.to.toggleTranslate(),
                  width: 32,
                  height: 32,
                  radius: 6,
                  iconColor: const Color(0xFF333333),
                  iconSize: 30);
            })
          ]));
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Obx(() {
            return materialButton(
                PlayerLogic.to.playingMusic.value.isLove
                    ? Icons.favorite
                    : "assets/player/play_love.svg",
                () => PlayerLogic.to.toggleLove(),
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
    return Obx(() {
      return SeekBar(
        duration: PlayerLogic.to.playingTotal.value,
        position: PlayerLogic.to.playingPosition.value,
        onChangeEnd: (newPosition) {
          PlayerLogic.to.seekTo(newPosition.inMilliseconds.truncate());
        }
      );
    });
  }

  Widget playButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Obx(() {
            String icon;
            final playMode = PlayerLogic.to.playMode.value;
            if (playMode == PlayMode.playlist) {
              icon = "assets/player/play_recycle.svg";
            } else if (playMode == PlayMode.single) {
              icon = "assets/player/play_single.svg";
            } else {
              icon = "assets/player/play_shuffle.svg";
            }
            return materialButton(icon, () => PlayerLogic.to.changePlayMode(),
                width: 32,
                height: 32,
                radius: 6,
                iconSize: 15,
                iconColor: const Color(0xFF333333));
          }),
          materialButton("assets/player/play_prev.svg",
              () => PlayerLogic.to.changePlayPrevOrNext(-1),
              width: 60, height: 60, radius: 40, iconSize: 16),
          Obx(() {
            return materialButton(
                PlayerLogic.to.isPlaying.value
                    ? "assets/player/play_pause.svg"
                    : "assets/player/play_play.svg",
                () => PlayerLogic.to.togglePlay(),
                width: 80,
                height: 80,
                radius: 40,
                iconSize: 26);
          }),
          materialButton("assets/player/play_next.svg",
              () => PlayerLogic.to.changePlayPrevOrNext(1),
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
