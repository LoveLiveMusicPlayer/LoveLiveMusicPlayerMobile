import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

///歌曲
class ListViewItemSong extends StatefulWidget {
  final int index;
  final List<Music> musicList;
  final Function(int, bool) onItemTap;
  final Function(Music) onMoreTap;
  final bool isDraggable;

  ///当前选中状态
  bool checked;

  ListViewItemSong(
      {super.key,
      required this.index,
      required this.musicList,
      required this.onItemTap,
      required this.onMoreTap,
      this.isDraggable = false,
      this.checked = false});

  @override
  State<ListViewItemSong> createState() => ListViewItemSongState();
}

class ListViewItemSongState extends State<ListViewItemSong> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasBGPhoto = GlobalLogic.to.bgPhoto.value != "";
      final music = widget.musicList[widget.index];
      final imagePath = SDUtils.getImgPathFromMusic(music);
      return Row(
        children: [
          /// 标记当前播放歌曲
          Container(
            width: 5.w,
            height: 48.h,
            color: isPlayingMusic ? ColorMs.colorFFAE00 : Colors.transparent,
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 11.w),
              child: Row(
                children: [
                  /// 勾选按钮
                  Visibility(
                    visible: HomeController.to.state.selectMode.value == 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: CircularCheckBox(
                        checked: widget.checked,
                        onChecked: onItemTap,
                        iconSize: 25,
                        checkIconColor: ColorMs.colorF940A7,
                        uncheckedIconColor: ColorMs.colorD6D6D6,
                      ),
                    ),
                  ),

                  /// 缩列图
                  GestureDetector(
                    onTap: clickItem,
                    child: showImg(imagePath, 48, 48, onTap: clickItem),
                  ),

                  SizedBox(width: 10.w),

                  /// 中间标题部分
                  Expanded(
                    child: GestureDetector(
                      onTap: clickItem,
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(music.musicName ?? "",
                                style: hasBGPhoto
                                    ? TextStyleMs.white_15_500
                                    : isPlayingMusic
                                        ? TextStyleMs.orange_15_500
                                        : GlobalLogic.to.isDarkTheme.value
                                            ? TextStyleMs.white_15_500
                                            : TextStyleMs.black_15_500,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            SizedBox(height: 4.h),
                            Text(
                              music.artist ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyleMs.f12_400.copyWith(
                                  color: hasBGPhoto
                                      ? ColorMs.colorD6D6D6
                                      : isPlayingMusic
                                          ? ColorMs.colorFFAE00
                                          : ColorMs.color999999),
                            ),
                            SizedBox(width: 16.h)
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// 右侧操作按钮
                  _buildAction(),
                ],
              ),
            ),
          )
        ],
      );
    });
  }

  /// 右侧操作按钮
  Widget _buildAction() {
    final color = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? ColorMs.colorDFDFDF
        : ColorMs.colorCCCCCC;
    if (HomeController.to.state.selectMode.value == 1) {
      if (widget.isDraggable) {
        return neumorphicButton(Assets.mainIcDraggable, null,
            width: 20,
            height: 20,
            iconColor: color,
            hasShadow: false,
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            padding: const EdgeInsets.all(0));
      } else {
        return const Row();
      }
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          neumorphicButton(
            Assets.mainIcAddNext,
            onPlayNextTap,
            width: 30,
            height: 30,
            iconColor: color,
            hasShadow: false,
            margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 12.h),
          ),
          neumorphicButton(
            Assets.mainIcMore,
            onMoreTap,
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

  bool get isPlayingMusic =>
      widget.musicList[widget.index].musicId ==
      PlayerLogic.to.playingMusic.value.musicId;

  clickItem() {
    if (HomeController.to.state.selectMode.value == 1) {
      onItemTap(!widget.checked);
    } else {
      onPlayTap();
    }
  }

  onItemTap(bool isChecked) {
    widget.checked = isChecked;
    widget.onItemTap(widget.index, isChecked);
    setState(() {});
  }

  onPlayNextTap() {
    PlayerLogic.to.addNextMusic(widget.musicList[widget.index]);
    SmartDialog.showToast('add_success'.tr);
  }

  onPlayTap() {
    PageViewLogic.to.play(widget.musicList, widget.index);
  }

  onMoreTap() {
    widget.onMoreTap(widget.musicList[widget.index]);
  }
}
