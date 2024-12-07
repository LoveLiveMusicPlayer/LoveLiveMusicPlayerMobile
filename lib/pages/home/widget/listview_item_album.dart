import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

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
    final style = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? TextStyle(fontSize: 12).copyWith(color: ColorMs.colorFFFFFF)
        : TextStyle(fontSize: 12).copyWith(color: Colors.black);

    return GestureDetector(
        onTap: () => onItemTap(album),
        child: Column(
          children: [
            Hero(
              tag: "album${album.albumId}",
              child: SizedBox(
                height: 146.h, // 确保容器高度一致
                child: showImg(
                  SDUtils.getImgPathFromAlbum(album),
                  146,
                  146,
                  hasShadow: false,
                  onTap: () => onItemTap(album),
                ),
              ),
            ),
            SizedBox(
              height: 30.h,
              child: Text(
                album.albumName!,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            )
          ],
        ));
  }
}
