import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

///歌单
class ListViewItemPlaylist extends StatefulWidget {
  int index;
  String name;
  String artist;
  Function(int) onDelTap;
  Function(int) onPlayTap;

  ListViewItemPlaylist(
      {Key? key,
      required this.index,
      required this.name,
      required this.artist,
      required this.onDelTap,
      required this.onPlayTap})
      : super(key: key);

  @override
  State<ListViewItemPlaylist> createState() => _ListViewItemPlaylist();
}

class _ListViewItemPlaylist extends State<ListViewItemPlaylist> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.primaryColor,
      child: Row(
        children: [
          _buildContent(),
        ],
      ),
    );
  }

  ///中间标题部分
  Widget _buildContent() {
    final screenWidth = Get.width - 33.w;
    final nameWidth = screenWidth * 0.5;
    final artistWidth = screenWidth * 0.4;
    return Container(
      height: 30.h,
      width: screenWidth,
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => widget.onPlayTap(widget.index),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: nameWidth),
                  child: Text(widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Get.isDarkMode
                          ? TextStyleMs.whiteBold_14
                          : TextStyleMs.black_18_bold),
                ),
                SizedBox(
                  width: 4.w,
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: artistWidth),
                  child: Text(
                    "-${widget.artist}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyleMs.gray_12_bold,
                  ),
                )
              ],
            ),
          ),
          touchIconByAsset(
              path: Assets.dialogIcDelete,
              onTap: () {
                widget.onDelTap(widget.index);
              },
              width: 16.h,
              height: 16.h,
              color: ColorMs.color999999)
        ],
      ),
    );
  }
}
