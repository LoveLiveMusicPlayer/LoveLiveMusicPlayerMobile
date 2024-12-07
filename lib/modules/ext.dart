import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

/// 显示图片
///
/// [path] 图片路径
/// [width] 显示的宽度
/// [height] 显示的高度
/// [radius] 圆角度数
Widget showImg(
  String? path,
  double? width,
  double? height, {
  double radius = 12,
  bool isCircle = false,
  String defPhoto = Assets.logoLogo,
  BoxFit fit = BoxFit.fill,
  GestureTapCallback? onTap,
  GestureTapCallback? onLongPress,
}) {
  var def = Image.asset(defPhoto, width: width?.h, height: width?.h, fit: fit);
  ImageProvider<Object> imageProvider = def.image;
  if (path == null || path.isEmpty) {
  } else if (path.startsWith("http")) {
    Widget widget = CachedNetworkImage(
        width: width?.h,
        height: width?.h,
        cacheManager: AppUtils.cacheManager,
        imageUrl: path,
        imageBuilder: (context, imageProvider) => Image(image: imageProvider),
        placeholder: (context, url) => def,
        errorWidget: (context, url, error) => def);
    Widget clip;
    if (isCircle) {
      clip = ClipOval(child: widget);
    } else {
      clip = ClipRRect(
          borderRadius: BorderRadius.circular(radius.h), child: widget);
    }
    return GestureDetector(
        onTap: () => onTap?.call(),
        onLongPress: () => onLongPress?.call(),
        child: clip);
  } else if (path.startsWith("assets")) {
    imageProvider =
        Image.asset(path, width: width?.h, height: width?.h, fit: fit).image;
  } else {
    final file = File(path);
    if (file.existsSync()) {
      imageProvider =
          Image.file(File(path), width: width?.h, height: width?.h, fit: fit)
              .image;
    }
  }
  Widget clip;
  Widget widget =
      Image(image: imageProvider, width: width?.h, height: height?.h, fit: fit);
  if (isCircle) {
    clip = ClipOval(child: widget);
  } else {
    clip =
        ClipRRect(borderRadius: BorderRadius.circular(radius.h), child: widget);
  }
  return GestureDetector(
      onTap: () => onTap?.call(),
      onLongPress: () => onLongPress?.call(),
      child: clip);
}

/// 具有拟态风格的按钮
/// https://material.io/resources/icons
///
/// [icon] 支持Icons包下的按钮、本地assets资源
/// [onTap] 触摸事件回调
/// [width] 控件宽度
/// [height] 控件高度
/// [margin] 外边距
/// [padding] 内边距
/// [radius] 控件圆角度数
/// [shadowColor] 外阴影颜色
/// [iconSize] 内部图标的大小
/// [iconColor] 内部图标的颜色
/// [bgColor] 控件背景颜色
/// [hasShadow] 是否显示阴影
Widget neumorphicButton(dynamic icon, GestureTapCallback? onTap,
    {double width = 32,
    double height = 32,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double radius = 6,
    Color? shadowColor,
    double iconSize = 15,
    Color? iconColor,
    Color? bgColor,
    bool svgColorFilter = true,
    bool hasShadow = true}) {
  Widget child;
  iconColor =
      iconColor ?? (Get.isDarkMode ? Colors.white : ColorMs.color333333);
  if (icon is IconData) {
    child = Icon(icon, color: iconColor, size: iconSize.h);
  } else if (icon is String &&
      icon.startsWith("assets") &&
      icon.endsWith(".svg")) {
    final colorFilter = ColorFilter.mode(iconColor, BlendMode.srcIn);
    child = SvgPicture.asset(icon,
        colorFilter: svgColorFilter ? colorFilter : null,
        width: iconSize.h,
        height: iconSize.h);
  } else if (icon is String && icon.startsWith("assets")) {
    child =
        Image(image: AssetImage(icon), width: iconSize.h, height: iconSize.h);
  } else if (icon.endsWith(".gif")) {
    child = Image.asset(icon, width: iconSize.h, height: iconSize.h);
  } else {
    child = Container();
  }
  shadowColor = shadowColor ??
      (Get.isDarkMode ? ColorMs.color05080C : ColorMs.colorD3E0EC);
  return Container(
    width: width.h,
    height: height.h,
    margin: margin ?? const EdgeInsets.all(0),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius.r),
    ),
    child: NeumorphicButton(
        pressed: onTap != null,
        onPressed: onTap,
        style: NeumorphicStyle(
          color: bgColor ?? Colors.transparent,
          shape: NeumorphicShape.flat,
          lightSource: LightSource.bottomRight,
          shadowLightColor: shadowColor,
          shadowDarkColor: shadowColor,
          depth: hasShadow ? 3 : 0,
          boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.all(Radius.circular(radius.r))),
        ),
        padding: padding ?? EdgeInsets.all(5.r),
        child: child),
  );
}

/// 团组按钮
///
/// [path] 图片文件路径
/// [onTap] 触摸事件回调
Widget showGroupButton(String path, {GestureTapCallback? onTap}) {
  return neumorphicButton(path, onTap,
      width: 120,
      height: 50,
      radius: 8,
      svgColorFilter: false,
      padding: const EdgeInsets.all(0));
}
