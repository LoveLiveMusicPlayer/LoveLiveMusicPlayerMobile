import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/player/mini_player/logic.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:marquee_text/marquee_text.dart';

class MiniPlayer extends GetView<MiniPlayerController> {
  final GestureTapCallback onTap;

  const MiniPlayer(this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(34.r)),
        child: Obx(() {
          return Container(
            height: 60.h,
            margin: EdgeInsets.only(top: 6.h, left: 16.w, right: 16.w),
            decoration: controller.createDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey.withOpacity(0.15),
                    child: Row(children: [
                      SizedBox(width: 6.w),

                      /// 迷你封面
                      miniCover(),
                      SizedBox(width: 8.w),

                      /// 滚动歌名
                      Expanded(child: marqueeMusicName()),
                      SizedBox(width: 8.w),

                      /// 播放按钮
                      SizedBox(child: playButton()),
                      SizedBox(width: 1.w),

                      /// 播放列表按钮
                      playlistButton(),
                      SizedBox(width: 8.w)
                    ])),
              ),
            ),
          );
        }));
  }

  Widget miniCover() {
    final imagePath = controller.getCurrentPlayingMusicPath();
    return showImg(imagePath, 48, 48, isCircle: true, onTap: onTap);
  }

  Widget marqueeMusicName() {
    const textStyle = TextStyle(fontWeight: FontWeight.bold);
    final musicName = PlayerLogic.to.playingMusic.value.musicName;
    return Listener(
      onPointerDown: controller.onMarqueeTouchDown,
      onPointerUp: controller.onMarqueeTouchUp,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: SizedBox(
                width: constraints.maxWidth,
                child: GestureDetector(
                  onDoubleTap: PlayerLogic.to.togglePlay,
                  child: Center(
                    child: MarqueeText(
                        text: TextSpan(text: musicName ?? 'no_songs'.tr),
                        style: Get.isDarkMode
                            ? TextStyleMs.white_14.merge(textStyle)
                            : TextStyleMs.black_14.merge(textStyle),
                        speed: 15),
                  ),
                ),
              ));
        },
      ),
    );
  }

  Widget playButton() {
    final player = PlayerLogic.to.mPlayer;
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        final color =
            Get.isDarkMode ? ColorMs.colorCCCCCC : ColorMs.color333333;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(8.r),
            width: 16.r,
            height: 16.r,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return neumorphicButton(Assets.playerPlayPlay, () {
            if (PlayerLogic.to.playingMusic.value.musicId != null) {
              player.play();
            }
          }, width: 30, height: 30, iconColor: color, hasShadow: false);
        } else if (processingState != ProcessingState.completed) {
          return neumorphicButton(Assets.playerPlayPause, player.pause,
              width: 30, height: 30, iconColor: color, hasShadow: false);
        } else {
          int index = player.effectiveIndices!.first;
          return neumorphicButton(Assets.playerPlayPlay,
              () => player.seek(Duration.zero, index: index),
              width: 30, height: 30, iconColor: color, hasShadow: false);
        }
      },
    );
  }

  Widget playlistButton() {
    return neumorphicButton(
        Assets.playerPlayPlaylist, controller.showPlaylistDialog,
        width: 30,
        height: 30,
        hasShadow: false,
        iconColor: Get.isDarkMode ? ColorMs.colorCCCCCC : ColorMs.color333333);
  }
}
