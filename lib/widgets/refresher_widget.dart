import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefresherWidget extends StatefulWidget {
  Widget Function(BuildContext context, int index) listItem;
  Function(RefreshController controller) onRefresh;
  Function(RefreshController controller) onLoading;
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

  /// 长宽比

  RefresherWidget({
    Key? key,
    required this.itemCount,
    required this.listItem,
    required this.onRefresh,
    required this.onLoading,
    this.emptyMsg = "暂无数据",
    this.emptyImg = "assets/main/ic_null.png",
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
            style: TextStyle(fontSize: 18.sp, color: const Color(0xffbfbfbf)),
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
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        child: !widget.isGridView
            ? ListView.separated(
                itemCount: widget.itemCount,
                itemBuilder: widget.listItem,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    color: widget.spacingColor,
                    height: widget.mainAxisSpacing,
                  );
                },
              )
            : GridView.builder(
                itemCount: widget.itemCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: widget.aspectRatio,
                  crossAxisCount: widget.columnNum,
                  mainAxisSpacing: widget.mainAxisSpacing,
                  crossAxisSpacing: widget.crossAxisSpacing,
                ),
                itemBuilder: widget.listItem),
        onRefresh: () async {
          widget.onRefresh(_controller);
        },
        onLoading: () async {
          widget.onLoading(_controller);
        },
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CupertinoActivityIndicator(),
                  SizedBox(width: 10),
                  Text("加载中")
                ],
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("松手,加载更多!");
            } else {
              body = const Text("没有更多数据了!");
            }
            return Container(
              height: 55.h,
              child: Center(child: body),
            );
          },
        ),
      ),
    );
  }
}
