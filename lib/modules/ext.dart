import 'dart:io';
import 'package:flutter/cupertino.dart';

Widget showImg(String path,
    {double width = 100, double height = 100, double radius = 20}) {
  Widget view;
  if (path.isNotEmpty) {
    if (path.contains("assets")) {
      view = Image.asset(path, width: width, height: height);
    } else if (path.contains("http")) {
      view = Image.network(path, width: width, height: height);
    } else {
      view = Image.file(File(path), width: width, height: height);
    }
  } else {
    view = Container();
  }
  return ClipRRect(borderRadius: BorderRadius.circular(radius), child: view);
}