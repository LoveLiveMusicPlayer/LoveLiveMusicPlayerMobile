import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

///歌单
class ListViewItemPlaylist extends StatefulWidget {
  final int index;
  final String musicId;
  final String name;
  final String artist;
  final Function(int) onDelTap;
  final Function(int) onPlayTap;

  const ListViewItemPlaylist(
      {super.key,
      required this.index,
      required this.musicId,
      required this.name,
      required this.artist,
      required this.onDelTap,
      required this.onPlayTap});

  @override
  State<ListViewItemPlaylist> createState() => _ListViewItemPlaylist();
}

class _ListViewItemPlaylist extends State<ListViewItemPlaylist> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.primaryColor,
      child: Obx(() {
        return Row(
          children: [
            _buildContent(),
          ],
        );
      }),
    );
  }

  ///中间标题部分
  Widget _buildContent() {
    final screenWidth = Get.width - 33.h;
    final isCurrentPlayIndex =
        widget.musicId == PlayerLogic.to.playingMusic.value.musicId;
    return GestureDetector(
        onTap: () => widget.onPlayTap(widget.index),
        child: Container(
          color: Colors.transparent,
          constraints: BoxConstraints(maxWidth: screenWidth),
          height: 34.h,
          width: screenWidth,
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.55),
                    child: Text(widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isCurrentPlayIndex
                            ? TextStyleMs.orangeBold_14
                            : Get.isDarkMode
                                ? TextStyleMs.whiteBold_14
                                : TextStyleMs.blackBold_14),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.35),
                    child: Text(
                      "-${widget.artist}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: isCurrentPlayIndex
                          ? TextStyleMs.orangeBold_12
                          : TextStyleMs.grayBold_12,
                    ),
                  )
                ],
              ),
              touchIconByAsset(
                  path: Assets.dialogIcDelete,
                  onTap: () {
                    widget.onDelTap(widget.index);
                  },
                  width: 20.h,
                  height: 20.h,
                  color: ColorMs.color999999)
            ],
          ),
        ));
  }
}
