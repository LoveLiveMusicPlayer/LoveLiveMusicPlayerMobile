import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

///专辑 item
class ListViewItemAlbum extends GetView {
  final Album album;
  final Function(Album) onItemTap;

  const ListViewItemAlbum({
    super.key,
    required this.album,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderWidth = (ScreenUtil().screenWidth - 72.w) / 3;
    final style = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? TextStyleMs.f12_400.copyWith(color: ColorMs.colorFFFFFF)
        : TextStyleMs.f12_400.copyWith(color: Colors.black);

    return GestureDetector(
      onTap: () => onItemTap(album),
      child: Column(
        children: [
          SizedBox(
            height: borderWidth,
            width: borderWidth,
            child: Hero(
              tag: "album${album.albumId}",
              child: showImg(
                SDUtils.getImgPathFromAlbum(album),
                borderWidth,
                borderWidth,
                hasShadow: false,
                onTap: () => onItemTap(album),
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  album.albumName!,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
