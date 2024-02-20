import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefresherWidget extends StatefulWidget {
  final Widget Function(BuildContext context, int index) listItem;
  final Function(RefreshController controller)? onRefresh;
  final Function(RefreshController controller)? onLoading;
  final int itemCount;
  final String? emptyMsg;
  final String emptyImg;
  final bool enablePullDown;
  final bool enablePullUp;
  final bool isGridView;
  final int columnNum;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Color spacingColor;
  final double leftPadding;
  final double rightPadding;
  final ScrollController? scrollController;
  final bool canReorder;

  const RefresherWidget({
    super.key,
    required this.itemCount,
    required this.listItem,
    this.onRefresh,
    this.onLoading,
    this.scrollController,
    this.emptyMsg,
    this.emptyImg = Assets.mainIcNull,
    this.enablePullUp = true,
    this.enablePullDown = true,
    this.isGridView = false,
    this.columnNum = 1,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
    this.spacingColor = Colors.transparent,
    this.leftPadding = 0,
    this.rightPadding = 0,
    this.canReorder = false,
  });

  @override
  State<RefresherWidget> createState() => _RefresherWidgetState();
}

class _RefresherWidgetState extends State<RefresherWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 空白页
        Visibility(visible: widget.itemCount <= 0, child: _buildNullWidget()),
        _buildListViewWidget(),
      ],
    );
  }

  /// 空白页
  Widget _buildNullWidget() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(widget.emptyImg, width: 80.h, height: 80.h),
          SizedBox(height: 10.h),
          Text(widget.emptyMsg ?? 'no_data'.tr,
              style: TextStyleMs.colorBFBFBF_18)
        ],
      ),
    );
  }

  final RefreshController _controller =
      RefreshController(initialRefresh: false);

  /// 列表
  Widget _buildListViewWidget() {
    return Padding(
      padding:
          EdgeInsets.only(left: widget.leftPadding, right: widget.rightPadding),
      child: SmartRefresher(
        enablePullDown: widget.enablePullDown,
        enablePullUp: widget.enablePullUp,
        controller: _controller,
        onRefresh: () async => widget.onRefresh?.call(_controller),
        onLoading: () async => widget.onLoading?.call(_controller),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(),
                  SizedBox(width: 10.r),
                  const Text("加载中")
                ],
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("松手,加载更多!");
            } else {
              body = const Text("没有更多数据了!");
            }
            return SizedBox(
              height: 55.h,
              child: Center(child: body),
            );
          },
        ),
        child: renderList(),
      ),
    );
  }

  Widget renderList() {
    if (widget.isGridView) {
      // Grid列表(专辑)
      return AlignedGridView.count(
          cacheExtent: 3000,
          controller: widget.scrollController,
          itemCount: widget.itemCount,
          crossAxisCount: widget.columnNum,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          itemBuilder: widget.listItem);
    } else {
      if (widget.canReorder) {
        // 可排序List列表(我喜欢)
        return ReorderableListView.builder(
          cacheExtent: 3000,
          buildDefaultDragHandles: widget.canReorder,
          proxyDecorator: (child, index, animation) {
            return child;
          },
          onReorderStart: (int index) => AppUtils.vibrate(),
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            setState(() {
              final Music child = GlobalLogic.to.loveList.removeAt(oldIndex);
              GlobalLogic.to.loveList.insert(newIndex, child);

              DBLogic.to.exchangeLoveItem(oldIndex, newIndex);
            });
          },
          scrollController: widget.scrollController,
          itemBuilder: widget.listItem,
          itemCount: widget.itemCount,
        );
      } else {
        // 不可排序List列表(其他)
        return ListView.separated(
          cacheExtent: 3000,
          itemCount: widget.itemCount,
          itemBuilder: widget.listItem,
          controller: widget.scrollController,
          separatorBuilder: (BuildContext context, int index) {
            return Container(
              color: widget.spacingColor,
              height: widget.mainAxisSpacing / 2,
            );
          },
        );
      }
    }
  }
}
