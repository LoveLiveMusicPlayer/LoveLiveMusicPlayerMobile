import 'dart:io';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 显示图片
///
/// [path] 图片路径
/// [width] 显示的宽度
/// [height] 显示的高度
/// [radius] 圆角度数
/// [hasShadow] 是否有阴影效果
Widget showImg(String path,
    {double width = 100,
    double height = 100,
    double radius = 20,
    bool hasShadow = true}) {
  Widget noShadowImage;
  ImageProvider<Object> shadowImage;
  if (hasShadow) {
    if (path.startsWith("assets")) {
      shadowImage = AssetImage(path);
    } else if (path.startsWith("http")) {
      shadowImage = NetworkImage(path);
    } else {
      shadowImage = FileImage(File(path));
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(image: shadowImage, fit: BoxFit.fill),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
              color: Color(0xFFD3E0EC), blurRadius: 4, offset: Offset(4, 8)),
        ],
      ),
    );
  } else {
    if (path.startsWith("assets")) {
      noShadowImage = Image.asset(path, width: width, height: height);
    } else if (path.startsWith("http")) {
      noShadowImage = Image.network(path, width: width, height: height);
    } else {
      noShadowImage = Image.file(File(path), width: width, height: height);
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius), child: noShadowImage);
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
Widget materialButton(IconData icon, Function onTap,
    {double width = 80,
    double height = 80,
    double radius = 20,
    Color innerColor = const Color(0xFFF2F8FF),
    Color outerColor = const Color(0xFFD3E0EC),
    double iconSize = 30,
    Color iconColor = Colors.black,
    EdgeInsets offset = const EdgeInsets.all(0)}) {
  return Container(
    width: width.w,
    height: height.h,
    decoration: BoxDecoration(
      color: innerColor,
      borderRadius: BorderRadius.circular(radius.w),
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
      borderRadius: BorderRadius.circular(radius.w),
      child: Material(
        color: const Color(0xFFF2F8FF),
        child: InkWell(
          splashColor: const Color(0xFFD3E0EC),
          highlightColor: const Color(0xFFD3E0EC),
          onTap: () => onTap,
          child: Stack(
            children: [
              Center(
                child: Icon(icon, color: iconColor, size: iconSize.w),
              ),
              Container(
                width: width.w,
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

Widget touchIcon(IconData icon, Function onTap, {Color color = const Color(0xff333333), double? size}) {
  return GestureDetector(
    onTap: () => onTap,
    child: Icon(icon, color: color, size: size),
  );
}

/// 覆盖背景
Widget coverBg({Color color = const Color(0xFFF2F8FF), double radius = 34}) {
  return Container(
    height: ScreenUtil().screenHeight,
    decoration:
        BoxDecoration(color: color, borderRadius: BorderRadius.circular(34)),
  );
}
