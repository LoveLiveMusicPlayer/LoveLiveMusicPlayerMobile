import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  final textStyle = GlobalLogic.to.hasSkin.value
      ? TextStyleMs.colorDFDFDF_12
      : TextStyleMs.gray_12;

  @override
  Widget build(BuildContext context) {
    final total = widget.duration.inMilliseconds;
    final current = widget.position.inMilliseconds;
    final totalMS =
        DateUtil.formatDate(DateUtil.getDateTimeByMs(total), format: "mm:ss");
    final currentMS =
        DateUtil.formatDate(DateUtil.getDateTimeByMs(current), format: "mm:ss");
    double value = min(_dragValue ?? current.toDouble(), total.toDouble());
    if (value > total.toDouble()) {
      value = total.truncate().toDouble();
    }
    if (value < 0.0) {
      value = 0.0;
    }
    return Column(
      children: [
        SliderTheme(
          data: const SliderThemeData(
              trackHeight: 4, thumbShape: RoundSliderThumbShape()),
          child: Slider(
            inactiveColor: GlobalLogic.to.hasSkin.value
                ? GlobalLogic.to.iconColor.value.withOpacity(0.3)
                : Get.isDarkMode
                    ? ColorMs.color272727
                    : ColorMs.colorCCDDF1.withAlpha(153),
            activeColor: GlobalLogic.to.hasSkin.value
                ? GlobalLogic.to.iconColor.value
                : Get.isDarkMode
                    ? ColorMs.color05080C.withAlpha(153)
                    : ColorMs.colorCCDDF1.withAlpha(153),
            thumbColor: GlobalLogic.to.hasSkin.value
                ? GlobalLogic.to.iconColor.value.withAlpha(255)
                : Get.isDarkMode
                    ? ColorMs.color05080C
                    : Get.theme.primaryColor,
            min: 0.0,
            max: total.toDouble(),
            value: value,
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
            },
            onChangeEnd: (value) {
              widget.onChangeEnd?.call(Duration(milliseconds: value.truncate()));
              _dragValue = null;
            },
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(currentMS, style: textStyle),
                Text(totalMS, style: textStyle)
              ],
            ))
      ],
    );
  }
}
