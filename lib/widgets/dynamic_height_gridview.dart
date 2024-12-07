library dynamic_height_grid_view;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

/// GridView with dynamic height
///
/// Usage is almost same as [GridView.count]
class DynamicHeightGridView extends StatelessWidget {
  const DynamicHeightGridView({
    super.key,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  });

  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final CrossAxisAlignment rowCrossAxisAlignment;

  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;

  int columnLength() {
    if (itemCount % crossAxisCount == 0) {
      return itemCount ~/ crossAxisCount;
    } else {
      return (itemCount ~/ crossAxisCount) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return _buildNullWidget();
    }
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      cacheExtent: 500,
      padding: EdgeInsets.zero,
      itemBuilder: (ctx, columnIndex) {
        return _GridRow(
          columnIndex: columnIndex,
          builder: builder,
          itemCount: itemCount,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisAlignment: rowCrossAxisAlignment,
        );
      },
      itemCount: columnLength(),
    );
  }

  /// 空白页
  Widget _buildNullWidget() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Assets.mainIcNull, width: 80.h, height: 80.h),
          SizedBox(height: 10.h),
          Text('no_data'.tr, style: TextStyleMs.colorBFBFBF_18)
        ],
      ),
    );
  }
}

/// Use this for [CustomScrollView]
class SliverDynamicHeightGridView extends StatelessWidget {
  const SliverDynamicHeightGridView({
    super.key,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
  });

  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final ScrollController? controller;

  int columnLength() {
    if (itemCount % crossAxisCount == 0) {
      return itemCount ~/ crossAxisCount;
    } else {
      return (itemCount ~/ crossAxisCount) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, columnIndex) {
          return _GridRow(
            columnIndex: columnIndex,
            builder: builder,
            itemCount: itemCount,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisAlignment: rowCrossAxisAlignment,
          );
        },
        childCount: columnLength(),
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.columnIndex,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.crossAxisAlignment,
  });

  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final int columnIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: (columnIndex == 0) ? 0 : mainAxisSpacing,
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: List.generate(
          (crossAxisCount * 2) - 1,
          (rowIndex) {
            final rowNum = rowIndex + 1;
            if (rowNum % 2 == 0) {
              return SizedBox(width: crossAxisSpacing);
            }
            final rowItemIndex = ((rowNum + 1) ~/ 2) - 1;
            final itemIndex = (columnIndex * crossAxisCount) + rowItemIndex;
            if (itemIndex > itemCount - 1) {
              return const Expanded(child: SizedBox());
            }
            return Expanded(
              child: builder(context, itemIndex),
            );
          },
        ),
      ),
    );
  }
}
