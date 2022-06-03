import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  ControlButtons(this.player);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          StreamBuilder<LoopMode>(
            stream: player.loopModeStream,
            builder: (context, snapshot) {
              final loopMode = snapshot.data ?? LoopMode.off;
              const icons = [
                "assets/player/play_shuffle.svg",
                "assets/player/play_recycle.svg",
                "assets/player/play_single.svg",
              ];
              final index = PlayerLogic.loopModes.indexOf(loopMode);
              return materialButton(icons[index], () async {
                PlayerLogic.to.changeLoopMode(PlayerLogic.loopModes.indexOf(loopMode) + 1);
              }, width: 32, height: 32, radius: 6, iconSize: 15);
            },
          ),
          StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => materialButton(
                "assets/player/play_prev.svg",
                () => player.hasPrevious ? player.seekToPrevious() : null,
                width: 60,
                height: 60,
                radius: 40,
                iconSize: 16),
          ),
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 64.0,
                  height: 64.0,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return materialButton(
                    "assets/player/play_play.svg", () => player.play(),
                    width: 80, height: 80, radius: 40, iconSize: 26);
              } else if (processingState != ProcessingState.completed) {
                return materialButton(
                    "assets/player/play_pause.svg", () => player.pause(),
                    width: 80, height: 80, radius: 40, iconSize: 26);
              } else {
                return materialButton(
                    "assets/player/play_play.svg",
                    () => player.seek(Duration.zero,
                        index: player.effectiveIndices!.first),
                    width: 80,
                    height: 80,
                    radius: 40,
                    iconSize: 26);
              }
            },
          ),
          StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => materialButton(
                "assets/player/play_next.svg",
                () => player.hasNext ? player.seekToNext() : null,
                width: 60,
                height: 60,
                radius: 40,
                iconSize: 16),
          ),
          materialButton("assets/player/play_playlist.svg", () => {},
              width: 32, height: 32, radius: 6, iconSize: 15),
        ],
      ),
    );
  }
}
