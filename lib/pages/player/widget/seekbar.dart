import 'dart:math';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({Key? key,
    required this.duration,
    required this.position,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

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
            inactiveColor: const Color(0xFFCCDDF1).withOpacity(0.6),
            activeColor: const Color(0xFFCCDDF1).withOpacity(0.6),
            thumbColor: Theme.of(Get.context!).primaryColor,
            min: 0.0,
            max: total.toDouble(),
            value: value,
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.truncate()));
              }
              _dragValue = null;
            },
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  currentMS,
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFF999999)),
                ),
                Text(
                  totalMS,
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFF999999)),
                )
              ],
            ))
      ],
    );
  }
}
