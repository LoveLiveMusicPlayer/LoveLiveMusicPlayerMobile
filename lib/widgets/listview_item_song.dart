import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

import '../pages/main/logic.dart';

///歌曲
class ListViewItemSong extends StatefulWidget {
  Function(int, bool) onItemTap;
  Function(int) onPlayTap;
  Function(int) onMoreTap;

  ///条目数据
  int index;

  ///当前是否处于勾选状态
  bool isSelect;

  ///当前选中状态
  bool checked;

  ListViewItemSong(
      {Key? key,
      required this.onItemTap,
      required this.onPlayTap,
      required this.onMoreTap,
      required this.index,
      this.checked = false,
      this.isSelect = false})
      : super(key: key);

  @override
  State<ListViewItemSong> createState() => _ListViewItemSongState();
}

class _ListViewItemSongState extends State<ListViewItemSong> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.checked = !widget.checked;
        widget.onItemTap(widget.index, widget.checked);
        setState(() {});
      },
      child: Container(
        color: const Color(0xFFF2F8FF),
        child: Row(
          children: [
            ///勾选按钮
            _buildCheckBox(),
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
  }

  ///缩列图
  Widget _buildIcon() {
    return showImg(SDUtils.getImgPath("ic_head.jpg"),
        width: 48, height: 48, hasShadow: false, radius: 8);
  }

  ///勾选按钮
  Widget _buildCheckBox() {
    return Visibility(
      visible: widget.isSelect,
      child: Padding(
        padding: EdgeInsets.only(right: 10.h),
        child: CircularCheckBox(
          checkd: widget.checked,
          onCheckd: (value) {
            widget.checked = value;
            widget.onItemTap(widget.index, widget.checked);
          },
          checkIconColor: Color(0xFFF940A7),
          uncheckedIconColor: Color(0xFF999999),
        ),
      ),
    );
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
    return Visibility(
      visible: !widget.isSelect,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.only(
                  left: 12.w, right: 12.w, top: 12.h, bottom: 12.h),
              child: touchIconByAsset(path:
              "assets/main/ic_add_next.svg",onTap: (){
                widget.onPlayTap(widget.index);
              },
                  width: 20, height: 20, color: const Color(0xFFCCCCCC))),
          InkWell(
            onTap: (){
              widget.onMoreTap(widget.index);
            },
            child: Container(
              padding: EdgeInsets.only(
                  left: 12.w, right: 10.w, top: 12.h, bottom: 12.h),
              child: touchIconByAsset(path: "assets/main/ic_more.svg", width: 10, height: 20, color: const Color(0xFFCCCCCC)),
            ),
          ),
          SizedBox(width: 4.w)
        ],
      ),
    );
  }
}
