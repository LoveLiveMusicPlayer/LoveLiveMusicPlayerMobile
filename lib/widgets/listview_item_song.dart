import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

///歌曲
class ListViewItemSong extends StatefulWidget {
  final Function(int, bool) onItemTap;
  final Function(Music) onPlayNextTap;
  final Function() onPlayTap;
  final Function(Music) onMoreTap;
  final bool isDraggable;

  ///条目数据
  final Music music;

  ///当前选中状态
  bool checked;

  final int index;

  ListViewItemSong(
      {super.key,
      required this.index,
      required this.onItemTap,
      required this.onPlayNextTap,
      required this.onPlayTap,
      required this.onMoreTap,
      required this.music,
      this.isDraggable = false,
      this.checked = false});

  @override
  State<ListViewItemSong> createState() => _ListViewItemSongState();
}

class _ListViewItemSongState extends State<ListViewItemSong> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          _buildPlaying(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w),
              child: Row(
                children: [
                  ///勾选按钮
                  _buildCheckBox(),

                  ///缩列图
                  _buildIcon(),

                  SizedBox(width: 10.r),

                  ///中间标题部分
                  _buildContent(),

                  ///右侧操作按钮
                  _buildAction(),
                ],
              ),
            ),
          )
        ],
      );
    });
  }

  clickItem() {
    widget.checked = !widget.checked;
    if (HomeController.to.state.selectMode.value == 1) {
      widget.onItemTap(widget.index, widget.checked);
    } else {
      widget.onPlayTap();
    }
    setState(() {});
  }

  onLongPress() async {}

  ///缩列图
  Widget _buildIcon() {
    return GestureDetector(
      onTap: clickItem,
      onLongPress:
          HomeController.to.state.selectMode.value == 0 ? onLongPress : null,
      child: showImg(SDUtils.getImgPathFromMusic(widget.music), 48, 48,
          hasShadow: false,
          onTap: clickItem,
          onLongPress: HomeController.to.state.selectMode.value == 0
              ? onLongPress
              : null),
    );
  }

  Widget _buildPlaying() {
    final isPlaying =
        widget.music.musicId == PlayerLogic.to.playingMusic.value.musicId;
    return Container(
      width: 5.w,
      height: 48.h,
      color: isPlaying ? ColorMs.colorFFAE00 : Colors.transparent,
    );
  }

  ///勾选按钮
  Widget _buildCheckBox() {
    return Visibility(
      visible: HomeController.to.state.selectMode.value == 1,
      child: Padding(
        padding: EdgeInsets.only(right: 10.h),
        child: CircularCheckBox(
          checked: widget.checked,
          onChecked: (value) {
            widget.checked = value;
            widget.onItemTap(widget.index, widget.checked);
          },
          checkIconColor: ColorMs.colorF940A7,
          uncheckedIconColor: ColorMs.colorD6D6D6,
        ),
      ),
    );
  }

  ///中间标题部分
  Widget _buildContent() {
    final isCurrentPlayingMusic =
        PlayerLogic.to.playingMusic.value.musicId == widget.music.musicId;
    final hasBGPhoto = GlobalLogic.to.bgPhoto.value != "";

    return Expanded(
      child: GestureDetector(
        onTap: clickItem,
        onLongPress:
            HomeController.to.state.selectMode.value == 0 ? onLongPress : null,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.music.musicName ?? "",
                  style: hasBGPhoto
                      ? TextStyleMs.white_15_500
                      : isCurrentPlayingMusic
                          ? TextStyleMs.orange_15_500
                          : GlobalLogic.to.isDarkTheme.value
                              ? TextStyleMs.white_15_500
                              : TextStyleMs.black_15_500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 4.h),
              Text(
                widget.music.artist ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyleMs.f12_400.copyWith(
                    color: hasBGPhoto
                        ? ColorMs.colorD6D6D6
                        : isCurrentPlayingMusic
                            ? ColorMs.colorFFAE00
                            : ColorMs.color999999),
              ),
              SizedBox(width: 16.w)
            ],
          ),
        ),
      ),
    );
  }

  ///右侧操作按钮
  Widget _buildAction() {
    final color = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? ColorMs.colorDFDFDF
        : ColorMs.colorCCCCCC;
    if (HomeController.to.state.selectMode.value == 1) {
      if (widget.isDraggable) {
        return neumorphicButton(
          Assets.mainIcDraggable,
          () {
            widget.onPlayNextTap(widget.music);
            SmartDialog.showToast('add_success'.tr);
          },
          width: 20,
          height: 20,
          iconColor: color,
          hasShadow: false,
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        );
      } else {
        return const Row();
      }
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          neumorphicButton(
            Assets.mainIcAddNext,
            () {
              widget.onPlayNextTap(widget.music);
              SmartDialog.showToast('add_success'.tr);
            },
            width: 30,
            height: 30,
            iconColor: color,
            hasShadow: false,
            margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 12.h),
          ),
          neumorphicButton(
            Assets.mainIcMore,
            () => widget.onMoreTap(widget.music),
            width: 30,
            height: 30,
            iconColor: color,
            hasShadow: false,
            margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 12.h),
          )
        ],
      );
    }
  }
}
