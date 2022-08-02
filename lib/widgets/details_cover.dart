import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class DetailsCover extends StatelessWidget {
  final Album album;

  const DetailsCover({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h, right: 16, top: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          showImg(SDUtils.getImgPath(fileName: album.coverPath!), 240, 240,
              radius: 24),
          SizedBox(
            height: 20.h,
          ),
          Text(
            album.albumName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Get.isDarkMode
                ? TextStyleMs.whiteBold_15
                : TextStyleMs.blackBold_15,
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            "${album.category}·${album.date}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: const Color(0xFF999999),
                fontSize: 12.sp,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
