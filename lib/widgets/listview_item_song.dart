import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

///歌曲
class ListViewItemSong extends StatefulWidget {
  final Function(int, bool) onItemTap;
  final Function(Music) onPlayNextTap;
  final Function() onPlayNowTap;
  final Function(Music) onMoreTap;

  ///条目数据
  final Music music;

  ///当前选中状态
  bool checked;

  final int index;

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
    if (HomeController.to.state.isSelect.value) {
      widget.onItemTap(widget.index, widget.checked);
    } else {
      widget.onPlayNowTap();
    }
    setState(() {});
  }

  onLongPress() async {
    if (!SDUtils.allowEULA) {
      return;
    }
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate();
    }
    if (!HomeController.to.state.isSelect.value) {
      SmartDialog.compatible.show(
          widget: TwoButtonDialog(
        title: "search_at_moe".tr,
        msg: "moe_address_error".tr,
        onConfirmListener: () async {
          final uri = Uri.parse(Const.moeGirlUrl + widget.music.musicName!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          }
        },
      ));
    }
  }

  ///缩列图
  Widget _buildIcon() {
    final coverPath = widget.music.baseUrl! + widget.music.coverPath!;
    return InkWell(
      onTap: clickItem,
      onLongPress: onLongPress,
      child: showImg(SDUtils.getImgPath(fileName: coverPath), 48, 48,
          hasShadow: false, onTap: clickItem, onLongPress: onLongPress),
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
      visible: HomeController.to.state.isSelect.value,
      child: Padding(
        padding: EdgeInsets.only(right: 10.h),
        child: CircularCheckBox(
          checkd: widget.checked,
          onCheckd: (value) {
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
      child: InkWell(
        onTap: clickItem,
        onLongPress: onLongPress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.music.musicName ?? "",
                style: hasBGPhoto
                    ? TextStyleMs.white_15_500
                    : isCurrentPlayingMusic
                        ? TextStyleMs.orange_15_500
                        : Get.isDarkMode
                            ? TextStyleMs.white_15_500
                            : TextStyleMs.black_15_500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            SizedBox(
              height: 4.h,
            ),
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
    final color = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? ColorMs.colorDFDFDF
        : ColorMs.colorCCCCCC;
    return Visibility(
      visible: !HomeController.to.state.isSelect.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: touchIconByAsset(
                  path: Assets.mainIcAddNext,
                  onTap: () {
                    widget.onPlayNextTap(widget.music);
                    SmartDialog.compatible.showToast('add_success'.tr);
                  },
                  width: 20,
                  height: 20,
                  color: color)),
          InkWell(
            onTap: () {
              widget.onMoreTap(widget.music);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: touchIconByAsset(
                  path: Assets.mainIcMore, width: 10, height: 20, color: color),
            ),
          ),
          SizedBox(width: 4.r)
        ],
      ),
    );
  }
}
