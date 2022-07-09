import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';

import 'my_lyric_ui.dart';

class Lyric extends StatefulWidget {
  final GestureTapCallback onTap;

  const Lyric({Key? key, required this.onTap}) : super(key: key);

  @override
  _LyricState createState() => _LyricState();
}

class _LyricState extends State<Lyric> {
  var lyricUI = MyLrcUI();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var model;
      switch (PlayerLogic.to.lrcType.value) {
        case 0:
          model = LyricsModelBuilder.create()
              .bindLyricToMain(PlayerLogic.to.fullLrc['jp']!)
              .getModel();
          break;
        case 1:
          model = LyricsModelBuilder.create()
              .bindLyricToMain(PlayerLogic.to.fullLrc['jp']!)
              .bindLyricToExt(PlayerLogic.to.fullLrc['zh']!)
              .getModel();
          break;
        case 2:
          model = LyricsModelBuilder.create()
              .bindLyricToMain(PlayerLogic.to.fullLrc['jp']!)
              .bindLyricToExt(PlayerLogic.to.fullLrc['roma']!)
              .getModel();
          break;
      }
      return LyricsReader(
        size: Size(ScreenUtil().screenWidth, 400.h),
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        model: model,
        position: PlayerLogic.to.playingPosition.value.inMilliseconds,
        lyricUi: lyricUI,
        playing: false,
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
            "暂无歌词",
            style: lyricUI.getOtherMainTextStyle(),
          ),
        ),
      );
    });
  }
}
