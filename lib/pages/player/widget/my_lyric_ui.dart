import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

///Sample Netease style
///should be extends LyricUI implementation your own UI.
///this property only for change UI,if not demand just only overwrite methods.
class MyLrcUI extends LyricUI {
  double defaultSize;
  double defaultExtSize;
  double otherMainSize;
  double bias;
  double lineGap;
  double inlineGap;
  LyricAlign lyricAlign;
  LyricBaseLine lyricBaseLine;
  bool highlight;

  MyLrcUI(
      {this.defaultSize = 15,
      this.defaultExtSize = 15,
      this.otherMainSize = 17,
      this.bias = 0.5,
      this.lineGap = 20,
      this.inlineGap = 8,
      this.lyricAlign = LyricAlign.CENTER,
      this.lyricBaseLine = LyricBaseLine.CENTER,
      this.highlight = false});

  MyLrcUI.clone(MyLrcUI ui)
      : this(
            defaultSize: ui.defaultSize,
            defaultExtSize: ui.defaultExtSize,
            otherMainSize: ui.otherMainSize,
            bias: ui.bias,
            lineGap: ui.lineGap,
            inlineGap: ui.inlineGap,
            lyricAlign: ui.lyricAlign,
            lyricBaseLine: ui.lyricBaseLine,
            highlight: ui.highlight);

  @override
  TextStyle getPlayingExtTextStyle() => TextStyle(
      color: Get.isDarkMode ? Colors.orangeAccent : Colors.black,
      fontSize: defaultSize.sp,
      fontWeight: FontWeight.bold);

  @override
  TextStyle getOtherExtTextStyle() => TextStyle(
        color: const Color(0xFF999999),
        fontSize: defaultSize.sp,
      );

  @override
  TextStyle getOtherMainTextStyle() =>
      TextStyle(color: const Color(0xFF999999), fontSize: otherMainSize.sp);

  @override
  TextStyle getPlayingMainTextStyle() => TextStyle(
      color: Get.isDarkMode ? Colors.orangeAccent : Colors.black,
      fontSize: otherMainSize.sp,
      fontWeight: FontWeight.bold);

  @override
  double getInlineSpace() => inlineGap;

  @override
  double getLineSpace() => lineGap;

  @override
  double getPlayingLineBias() => bias;

  @override
  LyricAlign getLyricHorizontalAlign() => lyricAlign;

  @override
  LyricBaseLine getBiasBaseLine() => lyricBaseLine;

  @override
  bool enableHighlight() => highlight;
}
