/*
 * 如果只有一个圆的情况下,请设置已完成的圆  默认的圆的颜色不要设置
 */
import 'dart:math';

import 'package:flutter/material.dart';

class CircleView extends CustomPainter {
  //默认的线的背景颜色
  Color? lineColor;
  //默认的线的宽度
  double width;
  //已完成线的颜色
  Color completeColor;
  //已完成的百分比
  double completePercent;
  //已完成的线的宽度
  double completeWidth;
  // 从哪开始 1从下开始, 2 从上开始 3 从左开始 4 从右开始  默认从下开始
  double startType;
  //是不是虚线的圈
  bool isDividerRound;
  //中间的实圆 统计线条是不是渐变的圆
  bool isGradient;
  //结束的位置
  double endAngle;
  //默认的线的背景颜色
  List<Color> lineColors;
  //实心圆阴影颜色
  // Color shadowColor;
  //渐变圆  深色在下面 还是在左面  默认在下面
  bool isTransfrom;

  CircleView({
    this.lineColor,
    required this.completeColor,
    required this.completePercent,
    this.width = 0,
    required this.completeWidth,
    this.startType = 1,
    this.isDividerRound = false,
    this.isGradient = false,
    this.endAngle = pi * 2,
    required this.lineColors,
    this.isTransfrom = false,
    // this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2); //  坐标中心
    double radius = min(size.width / 2, size.height / 2); //  半径

    //是否有第二层圆
    if (lineColor != null) {
      //是不是 虚线圆
      if (isDividerRound) {
        //背景的线
        Paint line = Paint()
          ..color = lineColor!
        // ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..strokeWidth = width;

        double i = 0.00;
        while (i < pi * 2) {
          canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i,
              0.04, false, line);
          i = i + 0.08;
        }
      } else {
        //背景的线  实线
        Paint line = Paint()
          ..color = lineColor!
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = width;

        canvas.drawCircle(
          //  画圆方法
            center,
            radius,
            line);
      }
    }
    //画上面的圆
    if (completeWidth > 0) {
      double arcAngle = 2 * pi * (completePercent / 100);

      // 从哪开始 1从下开始, 2 从上开始 3 从左开始 4 从右开始  默认从下开始
      double start = pi / 2;
      if (startType == 2) {
        start = -pi / 2;
      } else if (startType == 3) {
        start = pi;
      } else if (startType == 4) {
        start = pi * 2;
      }

      //创建画笔
      Paint paint = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = completeWidth;

      ///是渐变圆
      if (isGradient == true) {
        //渐变圆 深色位置偏移量  默认深色在下面
        double transfrom;
        if (isTransfrom == false) {
          //深色在下面
          transfrom = -pi / 2;
        } else {
          //深色在左面
          transfrom = pi * 2;
        }
        paint.shader = SweepGradient(
          startAngle: 0.0,
          endAngle: pi * 2,
          colors: lineColors,
          tileMode: TileMode.clamp,
          transform: GradientRotation(transfrom),
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start,
            arcAngle, false, paint);
      } else {
        ///是实体圆
        paint.color = completeColor;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          start, //  -pi / 2,从正上方开始  pi / 2,从下方开始
          arcAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CircleView oldDelegate) {
    return oldDelegate.completePercent != completePercent;
  }
}
