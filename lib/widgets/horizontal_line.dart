// Description：横线
import 'package:flutter/material.dart';

class HorizontalLine extends StatelessWidget {
  final double dashedWidth;
  final double dashedHeight;
  final Color color;

  const HorizontalLine({
    super.key,
    this.dashedHeight = 1,
    this.dashedWidth = double.infinity,
    this.color = const Color(0xFF979797),
  });

  @override
  Widget build(BuildContext context) {
    return Container(width: dashedWidth, height: dashedHeight, color: color);
  }
}
