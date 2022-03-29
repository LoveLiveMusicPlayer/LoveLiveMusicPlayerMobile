import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../network/http_request.dart';
import '../../main/logic.dart';
import 'my_lyric_ui.dart';

class Lyric extends StatefulWidget {
  final GestureTapCallback onTap;

  Lyric({required this.onTap});

  @override
  _LyricState createState() => _LyricState();
}

class _LyricState extends State<Lyric> {
  var lyricUI = MyLrcUI();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainLogic>(builder: (logic) {
      var model;
      switch(logic.state.lrcType) {
        case 0:
          model = LyricsModelBuilder.create()
              .bindLyricToMain(logic.state.jpLrc)
              .getModel();
          break;
        case 1:
          model = LyricsModelBuilder.create()
              .bindLyricToMain(logic.state.jpLrc)
              .bindLyricToExt(logic.state.zhLrc)
              .getModel();
          break;
        case 2:
          model = LyricsModelBuilder.create()
              .bindLyricToMain(logic.state.jpLrc)
              .bindLyricToExt(logic.state.romaLrc)
              .getModel();
          break;
      }
      return LyricsReader(
        size: Size(ScreenUtil().screenWidth, 440.h),
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        model: model,
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
    });
  }
}