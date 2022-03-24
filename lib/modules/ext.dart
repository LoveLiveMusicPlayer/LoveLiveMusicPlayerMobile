import 'dart:io';
import 'package:flutter/material.dart';

/// 显示图片
/// [path] 图片路径
/// [width] 显示的宽度
/// [height] 显示的高度
/// [radius] 圆角度数
/// [hasShadow] 是否有阴影效果
Widget showImg(String path,
    {double width = 100, double height = 100, double radius = 20, bool hasShadow = true}) {
  Widget noShadowImage;
  ImageProvider<Object> shadowImage;
  if (hasShadow) {
    if (path.contains("assets")) {
      shadowImage = AssetImage(path);
    } else if (path.contains("http")) {
      shadowImage = NetworkImage(path);
    } else {
      shadowImage = FileImage(File(path));
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(image: shadowImage, fit: BoxFit.fill),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0xFFD3E0EC),
              blurRadius: 4,
              offset: Offset(4, 8)
          ),
        ],
      ),
    );
  } else {
    if (path.contains("assets")) {
      noShadowImage = Image.asset(path, width: width, height: height);
    } else if (path.contains("http")) {
      noShadowImage = Image.network(path, width: width, height: height);
    } else {
      noShadowImage = Image.file(File(path), width: width, height: height);
    }
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: noShadowImage);
  }
}