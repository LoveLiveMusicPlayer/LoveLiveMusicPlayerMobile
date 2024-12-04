import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 多按钮布局，可用于单行及多行按钮布局
/// 平均分配每个按钮宽度，自适应每行最高高度
/// 可添加按钮之间的间距，可添加多行之间的间距
class OptionGridView extends StatelessWidget {
  final int itemCount;
  final int rowCount;
  final int columnCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final IndexedWidgetBuilder itemBuilder;

  /// [itemCount] 按钮总个数
  /// [rowCount] 每行按钮个数
  /// [mainAxisSpacing] 行间距
  /// [crossAxisSpacing] 按钮间距
  OptionGridView({
    super.key,
    required this.itemCount,
    required this.rowCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.padding = const EdgeInsets.all(0),
    required this.itemBuilder,
  })  : assert(itemCount >= 0),
        assert(rowCount > 0),
        columnCount = (itemCount / rowCount).ceil(),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: columnCount,
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      controller: ScrollController(keepScrollOffset: false),
      separatorBuilder: (context, index) => SizedBox(height: mainAxisSpacing),
      itemBuilder: (context, index) => buildRow(context, index),
    );
  }

  Widget buildRow(BuildContext context, int index) {
    if (index < columnCount - 1) {
      List<Widget> row = [];
      for (int i = 0; i < rowCount; i++) {
        row.add(Expanded(
          flex: 1,
          child: itemBuilder(context, i + index * rowCount),
        ));
        if (crossAxisSpacing > 0.0 && i < rowCount - 1) {
          row.add(SizedBox(width: crossAxisSpacing));
        }
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: row);
    } else {
      // 最后一行
      List<Widget> row = [];
      for (int i = 0; i < rowCount; i++) {
        int currentIndex = i + index * rowCount;
        if (currentIndex < itemCount) {
          row.add(Expanded(
            flex: 1,
            child: itemBuilder(context, i + index * rowCount),
          ));
          if (crossAxisSpacing > 0.0 && i < rowCount - 1) {
            row.add(SizedBox(width: crossAxisSpacing));
          }
        } else {
          row.add(const Expanded(flex: 1, child: SizedBox()));
        }
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: row);
    }
  }
}
