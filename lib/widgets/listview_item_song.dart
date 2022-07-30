import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

///歌曲
class ListViewItemSong extends StatefulWidget {
  Function(int, bool) onItemTap;
  Function(Music) onPlayNextTap;
  Function() onPlayNowTap;
  Function(Music) onMoreTap;

  ///条目数据
  Music music;

  ///当前选中状态
  bool checked;

  int index;

  ListViewItemSong(
      {Key? key,
      required this.index,
      required this.onItemTap,
      required this.onPlayNextTap,
      required this.onPlayNowTap,
      required this.onMoreTap,
      required this.music,
      this.checked = false})
      : super(key: key);

  @override
  State<ListViewItemSong> createState() => _ListViewItemSongState();
}

class _ListViewItemSongState extends State<ListViewItemSong>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      return Container(
        color: Get.theme.primaryColor,
        child: Row(
          children: [
            ///勾选按钮
            _buildCheckBox(),

            ///缩列图
            _buildIcon(),

            SizedBox(width: 10.w),

            ///中间标题部分
            _buildContent(),

            ///右侧操作按钮
            _buildAction(),
          ],
        ),
      );
    });
  }

  clickItem() {
    widget.checked = !widget.checked;
    if (HomeController.to.state.isSelect.value) {
      widget.onItemTap(widget.index, widget.checked);
    } else {
      widget.onPlayNowTap();
    }
    setState(() {});
  }

  ///缩列图
  Widget _buildIcon() {
    return InkWell(
      onTap: clickItem,
      child: showImg(
          SDUtils.getImgPath(widget.music.coverPath ?? "ic_head.jpg"), 48, 48,
          hasShadow: false, radius: 8),
    );
  }

  ///勾选按钮
  Widget _buildCheckBox() {
    return Visibility(
      visible: HomeController.to.state.isSelect.value,
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
      child: InkWell(
        onTap: clickItem,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.music.musicName ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.isDarkMode
                    ? TextStyleMs.white_15
                    : TextStyleMs.black_15),
            SizedBox(
              height: 4.w,
            ),
            Text(
              widget.music.artist ?? "",
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
      ),
    );
  }

  ///右侧操作按钮
  Widget _buildAction() {
    return Visibility(
      visible: !HomeController.to.state.isSelect.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.only(
                  left: 12.w, right: 12.w, top: 12.h, bottom: 12.h),
              child: touchIconByAsset(
                  path: Assets.mainIcAddNext,
                  onTap: () {
                    widget.onPlayNextTap(widget.music);
                  },
                  width: 20,
                  height: 20,
                  color: const Color(0xFFCCCCCC))),
          InkWell(
            onTap: () {
              widget.onMoreTap(widget.music);
            },
            child: Container(
              padding: EdgeInsets.only(
                  left: 12.w, right: 10.w, top: 12.h, bottom: 12.h),
              child: touchIconByAsset(
                  path: Assets.mainIcMore,
                  width: 10,
                  height: 20,
                  color: const Color(0xFFCCCCCC)),
            ),
          ),
          SizedBox(width: 4.w)
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
