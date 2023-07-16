import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class DetailsCover extends StatelessWidget {
  final Album album;

  const DetailsCover({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
              tag: "album${album.albumId}",
              child: showImg(SDUtils.getImgPathFromAlbum(album), 240, 240,
                  radius: 24)),
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Text(
              album.albumName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
                  ? TextStyleMs.whiteBold_15
                  : TextStyleMs.blackBold_15,
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            "${album.category}·${album.date}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GlobalLogic.to.bgPhoto.value != ""
                ? TextStyleMs.colorDFDFDF_12
                : TextStyleMs.grayBold_12,
          ),
        ],
      ),
    );
  }
}
