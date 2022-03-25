import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/song_library/logic.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

import '../logic.dart';

class ListViewItem extends StatefulWidget {
  Function(bool) onItemTap;
  Function() onPlayTap;
  Function() onMoreTap;

  ///条目数据
  int index;

  ///全选
  bool isSelect;

  ListViewItem({Key? key,
    required this.onItemTap,
    required this.onPlayTap,
    required this.onMoreTap,
    this.isSelect = false,
    required this.index})
      : super(key: key);

  @override
  State<ListViewItem> createState() => _ListViewItemState();
}

class _ListViewItemState extends State<ListViewItem> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainLogic>(
      builder: (logic) {
        return GestureDetector(
          onTap: () {
            logic.selectItem(widget.index, !logic.isItemChecked(widget.index));
            widget.onItemTap(logic.isItemChecked(widget.index));
          },
          child: Container(
            color: const Color(0xFFF2F8FF),
            height: 68.w,
            child: Row(
              children: [
                SizedBox(
                  width: 10.w,
                ),

                ///勾选按钮
                _buildCheckBox(),
                SizedBox(
                  width: 6.w,
                ),

                ///缩列图
                _buildIcon(),
                SizedBox(
                  width: 10.w,
                ),

                ///中间标题部分
                _buildContent(),

                ///右侧操作按钮
                _buildAction(),
              ],
            ),
          ),
        );
      },
    );
  }

  ///缩列图
  Widget _buildIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.w),
      child: Image.file(
        SdUtils.getImgFile("ic_head.jpg"),
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
      ),
    );
  }

  ///勾选按钮
  Widget _buildCheckBox() {
    return GetBuilder<MainLogic>(builder: (logic) {
      return Visibility(
        visible: logic.state.isSelect,
        child: Padding(
          padding: EdgeInsets.only(left: 6.w, right: 4.w),
          child: CircularCheckBox(
            checkd: logic.isItemChecked(widget.index),
            onCheckd: (value) {
              logic.selectItem(widget.index, value);
              widget.onItemTap(logic.isItemChecked(widget.index));
            },
            checkIconColor: Color(0xFFF940A7),
            uncheckedIconColor: Color(0xFF999999),
          ),
        ),
      );
    });
  }

  ///中间标题部分
  Widget _buildContent() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "START！！True dreams",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: const Color(0xff333333),
                fontSize: 15.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 4.w,
          ),
          Text(
            "Liella!",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xff999999),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(
            width: 16.w,
          )
        ],
      ),
    );
  }

  ///右侧操作按钮
  Widget _buildAction() {
    return GetBuilder<MainLogic>(builder: (logic) {
      return Visibility(
        visible: !logic.state.isSelect,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                widget.onPlayTap();
              },
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: Image.asset(
                  "assets/main/ic_play.jpg",
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.onMoreTap();
              },
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: Image.asset(
                  "assets/main/ic_more.jpg",
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
            SizedBox(
              width: 4.w,
            )
          ],
        ),
      );
    });
  }
}
