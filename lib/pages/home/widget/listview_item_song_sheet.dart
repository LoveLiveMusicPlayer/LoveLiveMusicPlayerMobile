import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

///歌单
class ListViewItemSongSheet extends StatefulWidget {
  Function(int) onItemTap;

  ///当前选中状态
  bool checked;

  int index;

  ListViewItemSongSheet({Key? key,
    required this.onItemTap,
    this.checked = false,
    required this.index})
      : super(key: key);

  @override
  State<ListViewItemSongSheet> createState() => _ListViewItemSongStateSheet();
}

class _ListViewItemSongStateSheet extends State<ListViewItemSongSheet>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      return InkWell(
        onTap: () {
          widget.checked = !widget.checked;
          if (HomeController.to.state.isSelect.value) {
            HomeController.to.selectItem(widget.index, widget.checked);
          } else {
            widget.onItemTap(widget.index);
          }
          setState(() {});
        },
        child: Container(
          color: const Color(0xFFF2F8FF),
          child: Row(
            children: [
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
    });
  }

  ///缩列图
  Widget _buildIcon() {
    return showImg(SDUtils.getImgPath("ic_head.jpg"), 48, 48,
        hasShadow: false, radius: 8);
  }

  ///中间标题部分
  Widget _buildContent() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            GlobalLogic.to.menuList[widget.index].name,
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
            "${GlobalLogic.to.menuList[widget.index].music?.length ?? 0}首",
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

  @override
  bool get wantKeepAlive => true;
}
