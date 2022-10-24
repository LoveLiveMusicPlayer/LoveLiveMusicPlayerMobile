import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefresherWidget extends StatefulWidget {
  Widget Function(BuildContext context, int index) listItem;
  Function(RefreshController controller)? onRefresh;
  Function(RefreshController controller)? onLoading;
  int itemCount;
  String emptyMsg;
  String emptyImg;
  bool enablePullDown;
  bool enablePullUp;
  bool isGridView;
  int columnNum;
  double mainAxisSpacing;
  double crossAxisSpacing;
  Color spacingColor;
  double leftPadding;
  double rightPadding;
  double aspectRatio;
  ScrollController? scrollController;

  /// 长宽比

  RefresherWidget({
    Key? key,
    required this.itemCount,
    required this.listItem,
    this.onRefresh,
    this.onLoading,
    this.scrollController,
    this.emptyMsg = "暂无数据",
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
    this.aspectRatio = 1.0,
  }) : super(key: key);

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
          Image.asset(
            widget.emptyImg,
            width: 80.h,
            height: 80.h,
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            widget.emptyMsg,
            style: TextStyle(fontSize: 18.sp, color: ColorMs.colorBFBFBF),
          )
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
        onRefresh: () async {
          if (widget.onRefresh != null) {
            widget.onRefresh!(_controller);
          }
        },
        onLoading: () async {
          if (widget.onLoading != null) {
            widget.onLoading!(_controller);
          }
        },
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
        child: !widget.isGridView
            ? ListView.separated(
                itemCount: widget.itemCount,
                itemBuilder: widget.listItem,
                controller: widget.scrollController,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    color: widget.spacingColor,
                    height: widget.mainAxisSpacing,
                  );
                },
              )
            : AlignedGridView.count(
                controller: widget.scrollController,
                itemCount: widget.itemCount,
                crossAxisCount: widget.columnNum,
                mainAxisSpacing: widget.mainAxisSpacing,
                crossAxisSpacing: widget.crossAxisSpacing,
                itemBuilder: widget.listItem),
      ),
    );
  }
}
