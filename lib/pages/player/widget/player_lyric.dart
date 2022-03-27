import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'my_lyric_ui.dart';

class Lyric extends StatefulWidget {
  final GestureTapCallback onTap;
  final String? jpLrc;
  final String? zhLrc;
  final String? romaLrc;

  Lyric({required this.onTap, this.jpLrc, this.zhLrc, this.romaLrc});

  @override
  _LyricState createState() => _LyricState();
}

class _LyricState extends State<Lyric> {

  var lyricUI = MyLrcUI();

  @override
  Widget build(BuildContext context) {
    var lyricModel = LyricsModelBuilder.create()
        .bindLyricToMain(widget.jpLrc ?? "")
        .bindLyricToExt(widget.zhLrc ?? "")
        .getModel();

    return LyricsReader(
      size: Size(ScreenUtil().screenWidth, 400.h),
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      model: lyricModel,
      position: 0,
      lyricUi: lyricUI,
      playing: false,
      onTap: widget.onTap,
      selectLineBuilder: (progress, confirm) {
        return Row(
          children: [
            IconButton(
                onPressed: () {

                },
                icon: const Icon(Icons.play_arrow, color: Colors.green)),
            Expanded(
              child: Container(
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
    );
  }
}