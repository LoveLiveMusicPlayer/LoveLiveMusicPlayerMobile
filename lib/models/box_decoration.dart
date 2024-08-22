import 'package:flutter/material.dart';

class BoxDecorationData {
  final int color;
  final double borderRadius;

  BoxDecorationData({required this.color, required this.borderRadius});

  BoxDecoration toBoxDecoration() {
    return BoxDecoration(
      color: Color(color),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}