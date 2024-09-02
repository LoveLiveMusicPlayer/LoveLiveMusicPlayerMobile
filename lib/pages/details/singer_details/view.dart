import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/details/singer_details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/view.dart';

class SingerDetailsPage extends DetailsPage<SingerDetailController> {
  const SingerDetailsPage({super.key});

  @override
  Widget renderCover() {
    return Container(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
              tag: "singer${controller.artist.uid}",
              child: showImg(controller.artist.photo, 240, 240, radius: 120))
        ],
      ),
    );
  }
}
