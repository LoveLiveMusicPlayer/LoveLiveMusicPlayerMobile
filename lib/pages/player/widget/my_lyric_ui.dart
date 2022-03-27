import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      {this.defaultSize = 18,
        this.defaultExtSize = 14,
        this.otherMainSize = 16,
        this.bias = 0.5,
        this.lineGap = 25,
        this.inlineGap = 25,
        this.lyricAlign = LyricAlign.CENTER,
        this.lyricBaseLine = LyricBaseLine.CENTER,
        this.highlight = true});

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
  TextStyle getPlayingExtTextStyle() =>
      TextStyle(color: const Color(0xFF333333), fontSize: defaultExtSize);

  @override
  TextStyle getOtherExtTextStyle() => TextStyle(
    color: const Color(0xFF999999),
    fontSize: defaultExtSize,
  );

  @override
  TextStyle getOtherMainTextStyle() =>
      TextStyle(color: const Color(0xFF999999), fontSize: otherMainSize);

  @override
  TextStyle getPlayingMainTextStyle() => TextStyle(
    color: Colors.white,
    fontSize: defaultSize.sp,
  );

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
