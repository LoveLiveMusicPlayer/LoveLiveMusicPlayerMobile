import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/pages/player/widget/my_lyric_ui.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class Lyric extends StatefulWidget {
  final GestureTapCallback onTap;

  const Lyric({Key? key, required this.onTap, required double height})
      : super(key: key);

  @override
  State<Lyric> createState() => _LyricState();
}

class _LyricState extends State<Lyric> {
  final lyricUI = MyLrcUI();

  @override
  Widget build(BuildContext context) {
    LyricsReaderModel? model;
    return Obx(() {
      if (PlayerLogic.to.needRefreshLyric.value) {
        PlayerLogic.to.needRefreshLyric.value = false;
        final lyric = PlayerLogic.to.fullLrc;
        switch (PlayerLogic.to.lrcType.value) {
          case 0:
            model = LyricsModelBuilder.create()
                .bindLyricToMain(lyric['jp']!)
                .getModel();
            break;
          case 1:
            if (SDUtils.allowEULA) {
              model = LyricsModelBuilder.create()
                  .bindLyricToMain(lyric['jp']!)
                  .bindLyricToExt(lyric['zh']!)
                  .getModel();
            } else {
              model = LyricsModelBuilder.create()
                  .bindLyricToMain(lyric['zh']!)
                  .bindLyricToExt(lyric['roma']!)
                  .getModel();
            }
            break;
          case 2:
            model = LyricsModelBuilder.create()
                .bindLyricToMain(lyric['jp']!)
                .bindLyricToExt(lyric['roma']!)
                .getModel();
            break;
        }
      }
      return LyricsReader(
        size: Size(ScreenUtil().screenWidth, 400.h),
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        model: model,
        position: PlayerLogic.to.playingPosition.value.inMilliseconds,
        lyricUi: lyricUI,
        playing: PlayerLogic.to.isPlaying.value,
        onTap: widget.onTap,
        selectLineBuilder: (progress, confirm) {
          return Row(
            children: [
              IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => PlayerLogic.to.seekTo(progress),
                  icon: const Icon(Icons.play_arrow, color: Colors.green)),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 15.w),
                  decoration: const BoxDecoration(color: Colors.green),
                  height: 1,
                  width: double.infinity,
                ),
              ),
              Text(
                DateUtil.formatDateMs(progress, format: 'mm:ss'),
                style: const TextStyle(color: Colors.green),
              )
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
