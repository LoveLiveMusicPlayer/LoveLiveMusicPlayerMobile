import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_playlist/view.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:marquee_text/marquee_text.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key, required this.onTap});

  final GestureTapCallback onTap;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final scrollList = <Widget>[];
  ImageProvider? provider;
  double startPosition = 0;
  final maxWidth = ScreenUtil().screenWidth - 85.w - 96.h;
  final player = PlayerLogic.to.mPlayer;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34.r),
        ),
        child: Obx(() => renderPanel()));
  }

  Widget renderPanel() {
    var boxDecoration = PlayerLogic.to.miniPlayerBoxDecorationData.value;
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(top: 6.h, left: 16.w, right: 16.w),
      decoration: boxDecoration.toBoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: body(),
        ),
      ),
    );
  }

  Widget body() {
    return Container(
        alignment: Alignment.center,
        color: Colors.grey.withOpacity(0.15),
        child: Row(children: [
          SizedBox(width: 6.w),

          /// 迷你封面
          miniCover(),
          SizedBox(width: 8.w),

          /// 滚动歌名
          marqueeMusicName(),
          SizedBox(width: 10.w),

          /// 播放按钮
          SizedBox(
            width: 30.w,
            height: 30.h,
            child: playButton(),
          ),
          SizedBox(width: 5.w),

          /// 播放列表按钮
          neumorphicButton(Assets.playerPlayPlaylist, () {
            SmartDialog.show(
                alignment: Alignment.bottomCenter,
                builder: (context) {
                  return const DialogPlaylist();
                });
          },
              width: 30,
              height: 30,
              hasShadow: false,
              iconColor:
                  Get.isDarkMode ? ColorMs.colorCCCCCC : ColorMs.color333333)
        ]));
  }

  Widget miniCover() {
    final currentMusic = PlayerLogic.to.playingMusic.value;
    return showImg(SDUtils.getImgPathFromMusic(currentMusic), 48, 48,
        radius: 48, hasShadow: false, onTap: widget.onTap);
  }

  Widget marqueeMusicName() {
    return Listener(
      onPointerDown: (event) {
        startPosition = event.position.dx;
      },
      onPointerUp: (event) {
        final playlistSize = PlayerLogic.to.mPlayList.length;
        if (playlistSize <= 1) {
          return;
        }
        final loopMode = player.loopMode;
        if (loopMode == LoopMode.one) {
          return;
        }
        final endPosition = event.position.dx;
        if ((endPosition - startPosition).abs() > 130.w) {
          // 距离大于50认为滑动切歌有效
          if (endPosition > startPosition) {
            PlayerLogic.to.playPrev();
          } else {
            PlayerLogic.to.playNext();
          }
        }
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: renderPlayingWidget(PlayerLogic.to.playingMusic.value.musicName),
      ),
    );
  }

  Widget renderPlayingWidget(String? musicName) {
    const textStyle = TextStyle(fontWeight: FontWeight.bold);
    return SizedBox(
      width: maxWidth,
      child: GestureDetector(
        onDoubleTap: PlayerLogic.to.togglePlay,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MarqueeText(
                text: TextSpan(text: musicName ?? 'no_songs'.tr),
                style: Get.isDarkMode
                    ? TextStyleMs.white_14.merge(textStyle)
                    : TextStyleMs.black_14.merge(textStyle),
                speed: 15)
          ],
        ),
      ),
    );
  }

  Widget playButton() {
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
            margin: const EdgeInsets.all(8.0),
            width: 30.w,
            height: 30.h,
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
          return neumorphicButton(
              Assets.playerPlayPlay,
              () => player.seek(Duration.zero,
                  index: player.effectiveIndices!.first),
              width: 30,
              height: 30,
              iconColor: color,
              hasShadow: false);
        }
      },
    );
  }
}
