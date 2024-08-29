import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_playlist.dart';
import 'package:lovelivemusicplayer/utils/player_util.dart';

class ControlButtons extends GetView {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasSkin = GlobalLogic.to.hasSkin.value;
      final bgColor = hasSkin ? GlobalLogic.to.iconColor.value : null;
      final iconColor = hasSkin ? Colors.white : null;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 80.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StreamBuilder<LoopMode>(
                stream: PlayerLogic.to.mPlayer.loopModeStream,
                builder: (context, snapshot) {
                  final loopMode = PlayerUtil.calcLoopMode(snapshot.data);
                  return materialButton(
                      PlayerUtil.getLoopIconFromLoopMode(loopMode),
                      () => PlayerUtil.changeLoopModeByLoopTap(loopMode),
                      width: 32,
                      height: 32,
                      radius: 6,
                      iconSize: 15,
                      hasShadow: !hasSkin,
                      iconColor: iconColor,
                      bgColor: bgColor,
                      outerColor: bgColor);
                },
              ),
              StreamBuilder<SequenceState?>(
                stream: PlayerLogic.to.mPlayer.sequenceStateStream,
                builder: (context, snapshot) {
                  return materialButton(
                      Assets.playerPlayPrev, PlayerLogic.to.playPrev,
                      width: 60,
                      height: 60,
                      radius: 40,
                      iconSize: 16,
                      hasShadow: !hasSkin,
                      iconColor: iconColor,
                      bgColor: bgColor,
                      outerColor: bgColor);
                },
              ),
              StreamBuilder<PlayerState>(
                stream: PlayerLogic.to.mPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;
                  final hasPlayingMusic = PlayerLogic.to.playingMusic.value;
                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return SizedBox(
                      width: 80.h,
                      height: 80.h,
                      child: const CircularProgressIndicator(),
                    );
                  } else if (playing != true) {
                    return materialButton(Assets.playerPlayPlay, () {
                      if (hasPlayingMusic.musicId != null) {
                        PlayerLogic.to.mPlayer.play();
                      }
                    },
                        radius: 40,
                        iconSize: 26,
                        hasShadow: !hasSkin,
                        iconColor: iconColor,
                        bgColor: bgColor,
                        outerColor: bgColor);
                  } else if (processingState != ProcessingState.completed) {
                    return materialButton(
                        Assets.playerPlayPause, PlayerLogic.to.mPlayer.pause,
                        radius: 40,
                        iconSize: 26,
                        hasShadow: !hasSkin,
                        iconColor: iconColor,
                        bgColor: bgColor,
                        outerColor: bgColor);
                  } else {
                    return materialButton(
                        Assets.playerPlayPlay,
                        () => PlayerLogic.to.mPlayer.seek(Duration.zero,
                            index:
                                PlayerLogic.to.mPlayer.effectiveIndices!.first),
                        radius: 40,
                        iconSize: 26,
                        hasShadow: !hasSkin,
                        iconColor: iconColor,
                        bgColor: bgColor,
                        outerColor: bgColor);
                  }
                },
              ),
              StreamBuilder<SequenceState?>(
                stream: PlayerLogic.to.mPlayer.sequenceStateStream,
                builder: (context, snapshot) {
                  return materialButton(
                      Assets.playerPlayNext, PlayerLogic.to.playNext,
                      width: 60,
                      height: 60,
                      radius: 40,
                      iconSize: 16,
                      hasShadow: !hasSkin,
                      iconColor: iconColor,
                      bgColor: bgColor,
                      outerColor: bgColor);
                },
              ),
              materialButton(Assets.playerPlayPlaylist, () {
                SmartDialog.show(
                    alignment: Alignment.bottomCenter,
                    builder: (context) {
                      return const DialogPlaylist();
                    });
              },
                  width: 32,
                  height: 32,
                  radius: 6,
                  iconSize: 15,
                  hasShadow: !hasSkin,
                  iconColor: iconColor,
                  bgColor: bgColor,
                  outerColor: bgColor)
            ],
          ),
        ),
      );
    });
  }
}
