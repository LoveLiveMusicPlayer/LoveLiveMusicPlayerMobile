import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_lyric.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/pages/player/widget/my_lyric_ui.dart';

class Lyric extends GetView {
  final GestureTapCallback onTap;

  const Lyric({super.key, required this.onTap, required double height});

  @override
  Widget build(BuildContext context) {
    final lyricUI = MyLrcUI();

    return Obx(() {
      return LyricsReader(
        size: Size(ScreenUtil().screenWidth, 400.h),
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        model: LyricLogic.lyricsModel.value,
        position: LyricLogic.playingPosition.value.inMilliseconds,
        lyricUi: lyricUI,
        playing: PlayerLogic.to.mPlayer.playing,
        onTap: onTap,
        selectLineBuilder: (progress, confirm) {
          return Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: Text(
                  DateUtil.formatDateMs(progress, format: 'mm:ss'),
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 15.w),
                  decoration: const BoxDecoration(color: Colors.green),
                  height: 1,
                  width: double.infinity,
                ),
              ),
              IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => PlayerLogic.to.seekToPlay(progress),
                  icon: const Icon(Icons.play_arrow, color: Colors.green))
            ],
          );
        },
        emptyBuilder: () => Center(
          child: Text(
            'no_lyrics'.tr,
            style: lyricUI.getOtherMainTextStyle(),
          ),
        ),
      );
    });
  }
}
