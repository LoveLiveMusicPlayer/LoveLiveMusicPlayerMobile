import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

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

void generateDecorationData(List<Object> args) async {
  final Music music = args[0] as Music;
  Color color = args[1] as Color;
  double radius = args[2] as double;
  final SendPort sendPort = args[3] as SendPort;

  String coverPath = (music.baseUrl ?? "") + (music.coverPath ?? "");
  if (coverPath.isNotEmpty) {
    final mColor = await AppUtils.getImagePalette(coverPath, color);
    if (mColor != null) {
      color = mColor;
    }
  }

  BoxDecorationData data = BoxDecorationData(
    color: color.value,
    borderRadius: radius,
  );

  sendPort.send(data);
}
