import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/details/album_details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/view.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class AlbumDetailsPage extends DetailsPage<AlbumDetailController> {
  const AlbumDetailsPage({super.key});

  @override
  Widget renderCover() {
    final imagePath = SDUtils.getImgPathFromAlbum(controller.album);
    return Column(
      children: [
        Hero(
            tag: "album${controller.album.albumId}",
            child: showImg(imagePath, 240, null)),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            controller.album.albumName ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
                ? TextStyleMs.whiteBold_15
                : TextStyleMs.blackBold_15,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          "${controller.album.category}·${controller.album.date}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GlobalLogic.to.bgPhoto.value != ""
              ? TextStyleMs.colorDFDFDF_12
              : TextStyleMs.grayBold_12,
        ),
      ],
    );
  }
}
