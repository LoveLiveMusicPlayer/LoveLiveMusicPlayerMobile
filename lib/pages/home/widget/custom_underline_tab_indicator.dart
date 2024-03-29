import 'package:flutter/material.dart';

///参考UnderlineTabIndicator,仅仅修改画笔StrokeCap.square 为 StrokeCap.round
class CustomUnderlineTabIndicator extends Decoration {
  /// Create an underline style selected tab indicator.
  ///
  /// The [borderSide] and [insets] arguments must not be null.
  const CustomUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.indicatorWeight = 5.0,
  });

  /// The color and weight of the horizontal line drawn below the selected tab.
  final BorderSide borderSide;
  final double indicatorWeight;

  /// Locates the selected tab's underline relative to the tab's boundary.
  ///
  /// The [TabBar.indicatorSize] property can be used to define the tab
  /// indicator's bounds in terms of its (centered) tab widget with
  /// [TabBarIndicatorSize.label], or the entire tab with
  /// [TabBarIndicatorSize.tab].
  final EdgeInsetsGeometry insets;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is UnderlineTabIndicator) {
      return UnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is UnderlineTabIndicator) {
      return UnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  UnderlinePainter createBoxPainter([VoidCallback? onChanged]) {
    return UnderlinePainter(this, onChanged);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    return Rect.fromLTWH(
      indicator.left + (indicator.width - indicatorWeight) / 2,
      indicator.bottom - indicatorWeight,
      indicatorWeight,
      borderSide.width,
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class UnderlinePainter extends BoxPainter {
  UnderlinePainter(this.decoration, VoidCallback? onChanged)
      : assert(decoration != null),
        super(onChanged);

  final CustomUnderlineTabIndicator? decoration;

  BorderSide? get borderSide => decoration?.borderSide;

  EdgeInsetsGeometry? get insets => decoration?.insets;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration? configuration) {
    assert(configuration != null);
    assert(configuration!.size != null);
    final Rect rect = offset & configuration!.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final Rect indicator = decoration!
        ._indicatorRectFor(rect, textDirection)
        .deflate(decoration!.borderSide.width / 2.0);
    final Paint paint = decoration!.borderSide.toPaint();
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round; //主要是修改此处  圆角
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
