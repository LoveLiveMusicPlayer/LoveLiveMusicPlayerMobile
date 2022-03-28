import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

import '../logic.dart';

class ListViewItemSong extends StatefulWidget {
  Function(bool) onItemTap;
  GestureTapCallback onPlayTap;
  GestureTapCallback onMoreTap;

  ///条目数据
  int index;

  ///全选
  bool isSelect;

  ListViewItemSong(
      {Key? key,
      required this.onItemTap,
      required this.onPlayTap,
      required this.onMoreTap,
      this.isSelect = false,
      required this.index})
      : super(key: key);

  @override
  State<ListViewItemSong> createState() => _ListViewItemSongState();
}

class _ListViewItemSongState extends State<ListViewItemSong> {
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
    return showImg(SDUtils.getImgPath("ic_head.jpg"),
        width: 48, height: 48, hasShadow: false, radius: 8);
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
            Padding(
                padding: EdgeInsets.only(
                    left: 12.w, right: 12.w, top: 12.h, bottom: 12.h),
                child: touchIconByAsset(
                    "assets/main/ic_add_next.svg", widget.onPlayTap,
                    width: 20, height: 20, color: const Color(0xFFCCCCCC))),
            Padding(
                padding: EdgeInsets.only(
                    left: 12.w, right: 18.w, top: 12.h, bottom: 12.h),
                child: touchIconByAsset(
                    "assets/main/ic_more.svg", widget.onMoreTap,
                    width: 20, height: 20, color: const Color(0xFFCCCCCC))),
            SizedBox(width: 4.w)
          ],
        ),
      );
    });
  }
}
