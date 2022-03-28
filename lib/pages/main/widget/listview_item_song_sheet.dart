import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

import '../logic.dart';

class ListViewItemSongSheet extends StatefulWidget {
  Function(bool) onItemTap;

  ///条目数据
  int index;

  ///全选
  bool isSelect;

  ListViewItemSongSheet(
      {Key? key,
      required this.onItemTap,
      this.isSelect = false,
      required this.index})
      : super(key: key);

  @override
  State<ListViewItemSongSheet> createState() => _ListViewItemSongStateSheet();
}

class _ListViewItemSongStateSheet extends State<ListViewItemSongSheet> {
  var logic = Get.find<MainLogic>();
  @override
  Widget build(BuildContext context) {
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
            ///勾选按钮
            _buildCheckBox(),
            ///缩列图
            _buildIcon(),
            SizedBox(
              width: 10.w,
            ),

            ///中间标题部分
            _buildContent(),

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
    return GetBuilder<MainLogic>(builder: (logic) {
      return Visibility(
        visible: logic.state.isSelect,
        child: Padding(
          padding: EdgeInsets.only(right: 10.h),
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
}
