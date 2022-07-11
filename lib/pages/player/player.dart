import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as RxDart;
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/PositionData.dart';
import 'package:lovelivemusicplayer/pages/home/widget/control_buttons.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_cover.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_lyric.dart';
import 'package:lovelivemusicplayer/pages/player/widget/seekbar.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import '../../modules/ext.dart';

class Player extends StatefulWidget {
  final GestureTapCallback onTap;
  var isCover = true.obs;

  Player({required this.onTap});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player>{
  /// slider 正在被滑动
  var isTouch = false.obs;

  Stream<PositionData> get _positionDataStream =>
      RxDart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          PlayerLogic.to.mPlayer.positionStream,
          PlayerLogic.to.mPlayer.bufferedPositionStream,
          PlayerLogic.to.mPlayer.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

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
    return Container(
      color: Get.theme.primaryColor,
      height: 557.h,
      child: Column(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top + 14.56.h),

          /// 头部
          PlayerHeader(onTap: widget.onTap),

          SizedBox(height: 10.h),

          /// 中间可切换的界面
          Obx(() => stackBody()),

          SizedBox(height: 10.h),

          /// 功能栏
          Obx(() => funcButton())
        ],
      ),
    );
  }

  Widget bottom() {
    return Container(
      height: ScreenUtil().screenHeight - 560.h,
      color: Get.theme.primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /// 滑动条
          slider(),

          SizedBox(height: 20.h),

          /// 播放器控制组件
          ControlButtons(PlayerLogic.to.mPlayer),
        ],
      ),
    );
    // return Expanded(child: Container(color: Colors.red,));
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
                width: 32, height: 32, radius: 6, iconSize: 20),
            Obx(() {
              var icon;
              switch (PlayerLogic.to.lrcType.value) {
                case 0:
                  icon = Assets.playerPlayJp;
                  break;
                case 1:
                  icon = Assets.playerPlayZh;
                  break;
                case 2:
                  icon = Assets.playerPlayRoma;
                  break;
              }
              return materialButton(
                  icon, () => PlayerLogic.to.toggleTranslate(),
                  width: 32, height: 32, radius: 6, iconSize: 30);
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
                    : Assets.playerPlayLove,
                () => PlayerLogic.to.toggleLove(),
                width: 32,
                height: 32,
                radius: 6,
                iconColor: Colors.pinkAccent,
                iconSize: 15);
          }),
          materialButton(Icons.add, () => {},
              width: 32, height: 32, radius: 6, iconSize: 20),
        ],
      ),
    );
  }

  Widget slider() {
    return StreamBuilder<PositionData>(
      stream: _positionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;
        return SeekBar(
          duration: positionData?.duration ?? Duration.zero,
          position: positionData?.position ?? Duration.zero,
          onChangeEnd: (newPosition) {
            PlayerLogic.to.mPlayer.seek(newPosition);
          },
        );
      },
    );
  }

  /// 覆盖背景
  Widget coverBg() {
    return Container(
      height: ScreenUtil().screenHeight,
      decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: BorderRadius.circular(34)),
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
