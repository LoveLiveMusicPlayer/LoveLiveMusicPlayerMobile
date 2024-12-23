import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

///歌手 item
class ListViewItemSinger extends GetView {
  final Artist artist;
  final Function(Artist) onItemTap;

  const ListViewItemSinger(
      {super.key, required this.artist, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Hero(
            tag: "singer${artist.uid}",
            child: showImg(artist.photo, 48, 48,
                isCircle: true, onTap: () => onItemTap(artist))),
        SizedBox(width: 10.w),
        Expanded(
          child: GestureDetector(
            onTap: () => onItemTap(artist),
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(artist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Get.isDarkMode || GlobalLogic.to.bgPhoto.value != ""
                              ? TextStyleMs.white_15_500
                              : TextStyleMs.black_15_500),
                  SizedBox(height: 4.h),
                  Text(
                    "${artist.music.length} ${'total_number_unit'.tr}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleMs.f12_400.copyWith(
                        color: GlobalLogic.to.bgPhoto.value == ""
                            ? ColorMs.color999999
                            : ColorMs.colorD6D6D6),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
      ],
    );
  }
}
