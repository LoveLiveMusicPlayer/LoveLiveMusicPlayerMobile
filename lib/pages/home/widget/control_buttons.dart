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
                  return neumorphicButton(
                      PlayerUtil.getLoopIconFromLoopMode(loopMode),
                      () => PlayerUtil.changeLoopModeByLoopTap(loopMode),
                      hasShadow: !hasSkin,
                      iconColor: iconColor,
                      bgColor: bgColor,
                      padding: EdgeInsets.all(9.r));
                },
              ),
              StreamBuilder<SequenceState?>(
                stream: PlayerLogic.to.mPlayer.sequenceStateStream,
                builder: (context, snapshot) {
                  return neumorphicButton(
                      Assets.playerPlayPrev, PlayerLogic.to.playPrev,
                      width: 60,
                      height: 60,
                      radius: 60,
                      hasShadow: !hasSkin,
                      iconColor: iconColor,
                      bgColor: bgColor,
                      padding: EdgeInsets.all(20.r));
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
                    return neumorphicButton(Assets.playerPlayPlay, () {
                      if (hasPlayingMusic.musicId != null) {
                        PlayerLogic.to.mPlayer.play();
                      }
                    },
                        width: 80,
                        height: 80,
                        radius: 40,
                        iconSize: 26,
                        hasShadow: !hasSkin,
                        iconColor: iconColor,
                        bgColor: bgColor,
                        padding: EdgeInsets.all(25.r));
                  } else if (processingState != ProcessingState.completed) {
                    return neumorphicButton(
                        Assets.playerPlayPause, PlayerLogic.to.mPlayer.pause,
                        width: 80,
                        height: 80,
                        radius: 40,
                        iconSize: 26,
                        hasShadow: !hasSkin,
                        iconColor: iconColor,
                        bgColor: bgColor,
                        padding: EdgeInsets.all(25.r));
                  } else {
                    return neumorphicButton(
                        Assets.playerPlayPlay,
                        () => PlayerLogic.to.mPlayer.seek(Duration.zero,
                            index:
                                PlayerLogic.to.mPlayer.effectiveIndices!.first),
                        width: 80,
                        height: 80,
                        radius: 40,
                        iconSize: 26,
                        hasShadow: !hasSkin,
                        iconColor: iconColor,
                        bgColor: bgColor,
                        padding: EdgeInsets.all(25.r));
                  }
                },
              ),
              StreamBuilder<SequenceState?>(
                stream: PlayerLogic.to.mPlayer.sequenceStateStream,
                builder: (context, snapshot) {
                  return neumorphicButton(
                      Assets.playerPlayNext, PlayerLogic.to.playNext,
                      width: 60,
                      height: 60,
                      radius: 40,
                      hasShadow: !hasSkin,
                      iconColor: iconColor,
                      bgColor: bgColor,
                      padding: EdgeInsets.all(20.r));
                },
              ),
              neumorphicButton(Assets.playerPlayPlaylist, () {
                SmartDialog.show(
                    alignment: Alignment.bottomCenter,
                    builder: (context) {
                      return const DialogPlaylist();
                    });
              },
                  hasShadow: !hasSkin,
                  iconColor: iconColor,
                  bgColor: bgColor,
                  padding: EdgeInsets.all(9.r))
            ],
          ),
        ),
      );
    });
  }
}
