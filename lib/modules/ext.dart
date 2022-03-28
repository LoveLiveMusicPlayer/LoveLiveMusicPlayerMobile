import 'dart:io';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/sd_utils.dart';

/// 显示图片
///
/// [path] 图片路径
/// [width] 显示的宽度
/// [height] 显示的高度
/// [radius] 圆角度数
/// [hasShadow] 是否有阴影效果
Widget showImg(String? path,
    {double width = 100,
    double height = 100,
    double radius = 20,
    bool hasShadow = true,
    String defPhoto = "assets/thumb/XVztg3oXmX4.jpg"}) {
  Widget noShadowImage;
  ImageProvider<Object> shadowImage;
  if (hasShadow) {
    if (path == null || path.isEmpty) {
      shadowImage = AssetImage(defPhoto);
    } else if (path.startsWith("assets")) {
      shadowImage = AssetImage(path);
    } else if (path.startsWith("http")) {
      shadowImage = NetworkImage(path);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        shadowImage = FileImage(File(path));
      } else {
        shadowImage = AssetImage(defPhoto);
      }
    }

    return Container(
      width: width.h,
      height: height.h,
      decoration: BoxDecoration(
        image: DecorationImage(image: shadowImage, fit: BoxFit.fill),
        borderRadius: BorderRadius.circular(radius.h),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFD3E0EC),
              blurRadius: 4,
              offset: Offset(4.h, 8.h)),
        ],
      ),
    );
  } else {
    if (path == null || path.isEmpty) {
      noShadowImage = Image.asset(defPhoto, width: width.h, height: height.h);
    } else if (path.startsWith("assets")) {
      noShadowImage = Image.asset(path, width: width.h, height: height.h);
    } else if (path.startsWith("http")) {
      noShadowImage = Image.network(path, width: width.h, height: height.h);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        noShadowImage =
            Image.file(File(path), width: width.h, height: height.h);
      } else {
        noShadowImage = Image.asset(defPhoto, width: width.h, height: height.h);
      }
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius.h), child: noShadowImage);
  }
}

/// 具有material风格的按钮
/// https://material.io/resources/icons
///
/// [icon] Icons包下的按钮
/// [onTap] 触摸事件回调
/// [width] 控件宽度
/// [height] 控件高度
/// [radius] 控件圆角度数
/// [innerColor] 内阴影颜色
/// [outerColor] 外阴影颜色
/// [iconSize] 内部图标的大小
/// [iconColor] 内部图标的颜色
/// [offset] 内部图标的偏移量
Widget materialButton(IconData icon, GestureTapCallback? onTap,
    {double width = 80,
    double height = 80,
    double radius = 20,
    Color innerColor = const Color(0xFFF2F8FF),
    Color outerColor = const Color(0xFFD3E0EC),
    double iconSize = 30,
    Color iconColor = Colors.black,
    EdgeInsets offset = const EdgeInsets.all(0)}) {
  return Container(
    width: width.h,
    height: height.h,
    decoration: BoxDecoration(
      color: innerColor,
      borderRadius: BorderRadius.circular(radius.h),
      boxShadow: [
        const BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurStyle: BlurStyle.inner,
            blurRadius: 6),
        BoxShadow(color: outerColor, offset: const Offset(5, 3), blurRadius: 6),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius.h),
      child: Material(
        color: const Color(0xFFF2F8FF),
        child: InkWell(
          splashColor: const Color(0xFFD3E0EC),
          highlightColor: const Color(0xFFD3E0EC),
          onTap: onTap,
          child: Stack(
            children: [
              Center(
                child: Icon(icon, color: iconColor, size: iconSize.h),
              ),
              Container(
                width: width.h,
                height: height.h,
                alignment: const Alignment(0, 0),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

/// 团组按钮
///
/// [path] 图片文件路径
/// [innerWidth] 图片宽度
/// [innerHeight] 图片高度
Widget showGroupButton(String path,
    {double innerWidth = 130, double innerHeight = 60}) {
  return Container(
    width: 118.h,
    height: 60.h,
    decoration: BoxDecoration(
      color: const Color(0xFFF2F8FF),
      borderRadius: BorderRadius.circular(8.h),
      boxShadow: const [
        BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurStyle: BlurStyle.inner,
            blurRadius: 6),
        BoxShadow(
            color: Color(0xFFD3E0EC), offset: Offset(5, 3), blurRadius: 6),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.h),
      child: Material(
        color: const Color(0xFFF2F8FF),
        child: InkWell(
          splashColor: const Color(0xFFD3E0EC),
          highlightColor: const Color(0xFFD3E0EC),
          onTap: () => {},
          child: Stack(
            children: [
              Center(
                child: Image.asset(path,
                    width: innerWidth.h, height: innerHeight.h),
              ),
              Container(
                width: 130.h,
                height: 60.h,
                alignment: const Alignment(0, 0),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Widget logoIcon(String path, {double width = 36, double height = 36, double radius = 18, EdgeInsetsGeometry? offset, GestureTapCallback? onTap}) {
  final margin = offset ?? const EdgeInsets.only(right: 0);
  return Center(
    child: Container(
        margin: margin,
        width: width.h,
        height: height.h,
        padding: EdgeInsets.all(3.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius.h),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFD3E0EC),
                  blurRadius: 10,
                  offset: Offset(5.h, 3.h)),
            ]),
        child: InkWell(
          onTap: onTap,
          child: showImg(SDUtils.getImgPath(path), radius: radius.h, hasShadow: false)
        )
    )
  );
}

Widget touchIcon(IconData icon, GestureTapCallback onTap,
    {Color color = const Color(0xff333333), double? size}) {
  return GestureDetector(
    onTap: () => onTap,
    child: Icon(icon, color: color, size: size),
  );
}
