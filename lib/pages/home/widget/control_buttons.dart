import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 80.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StreamBuilder<LoopMode>(
              stream: player.loopModeStream,
              builder: (context, snapshot) {
                var loopMode = snapshot.data ?? LoopMode.off;
                const icons = [
                  Assets.playerPlayShuffle,
                  Assets.playerPlayRecycle,
                  Assets.playerPlaySingle
                ];
                if (loopMode == LoopMode.all && player.shuffleModeEnabled) {
                  loopMode = LoopMode.off;
                }
                final index = PlayerLogic.loopModes.indexOf(loopMode);
                return materialButton(icons[index], () {
                  final currentIndex = PlayerLogic.loopModes.indexOf(loopMode);
                  final nextIndex =
                      (currentIndex + 1) % PlayerLogic.loopModes.length;
                  PlayerLogic.to.changeLoopMode(nextIndex);
                },
                    width: 32,
                    height: 32,
                    radius: 6,
                    iconSize: 15,
                    iconColor:
                        PlayerLogic.to.hasSkin.value ? Colors.white : null,
                    bgColor: PlayerLogic.to.hasSkin.value
                        ? const Color(0xFF1E2328)
                        : null,
                    outerColor:
                        PlayerLogic.to.hasSkin.value ? Colors.black : null);
              },
            ),
            StreamBuilder<SequenceState?>(
              stream: player.sequenceStateStream,
              builder: (context, snapshot) => materialButton(
                  Assets.playerPlayPrev,
                  () => player.hasPrevious ? player.seekToPrevious() : null,
                  width: 60,
                  height: 60,
                  radius: 40,
                  iconSize: 16,
                  iconColor: PlayerLogic.to.hasSkin.value ? Colors.white : null,
                  bgColor: PlayerLogic.to.hasSkin.value
                      ? const Color(0xFF1E2328)
                      : null,
                  outerColor:
                      PlayerLogic.to.hasSkin.value ? Colors.black : null),
            ),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
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
                      player.play();
                    }
                  },
                      width: 80,
                      height: 80,
                      radius: 40,
                      iconSize: 26,
                      iconColor:
                          PlayerLogic.to.hasSkin.value ? Colors.white : null,
                      bgColor: PlayerLogic.to.hasSkin.value
                          ? const Color(0xFF1E2328)
                          : null,
                      outerColor:
                          PlayerLogic.to.hasSkin.value ? Colors.black : null);
                } else if (processingState != ProcessingState.completed) {
                  return materialButton(
                      Assets.playerPlayPause, () => player.pause(),
                      width: 80,
                      height: 80,
                      radius: 40,
                      iconSize: 26,
                      iconColor:
                          PlayerLogic.to.hasSkin.value ? Colors.white : null,
                      bgColor: PlayerLogic.to.hasSkin.value
                          ? const Color(0xFF1E2328)
                          : null,
                      outerColor:
                          PlayerLogic.to.hasSkin.value ? Colors.black : null);
                } else {
                  return materialButton(
                      Assets.playerPlayPlay,
                      () => player.seek(Duration.zero,
                          index: player.effectiveIndices!.first),
                      width: 80,
                      height: 80,
                      radius: 40,
                      iconSize: 26,
                      iconColor:
                          PlayerLogic.to.hasSkin.value ? Colors.white : null,
                      bgColor: PlayerLogic.to.hasSkin.value
                          ? const Color(0xFF1E2328)
                          : null,
                      outerColor:
                          PlayerLogic.to.hasSkin.value ? Colors.black : null);
                }
              },
            ),
            StreamBuilder<SequenceState?>(
              stream: player.sequenceStateStream,
              builder: (context, snapshot) => materialButton(
                  Assets.playerPlayNext,
                  () => player.hasNext ? player.seekToNext() : null,
                  width: 60,
                  height: 60,
                  radius: 40,
                  iconSize: 16,
                  iconColor: PlayerLogic.to.hasSkin.value ? Colors.white : null,
                  bgColor: PlayerLogic.to.hasSkin.value
                      ? const Color(0xFF1E2328)
                      : null,
                  outerColor:
                      PlayerLogic.to.hasSkin.value ? Colors.black : null),
            ),
            materialButton(Assets.playerPlayPlaylist, () => {},
                width: 32,
                height: 32,
                radius: 6,
                iconSize: 15,
                iconColor: PlayerLogic.to.hasSkin.value ? Colors.white : null,
                bgColor: PlayerLogic.to.hasSkin.value
                    ? const Color(0xFF1E2328)
                    : null,
                outerColor: PlayerLogic.to.hasSkin.value ? Colors.black : null),
          ],
        ),
      ),
    );
  }
}
