import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/view.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class MenuDetailsPage extends DetailsPage<MenuDetailController> {
  const MenuDetailsPage({super.key});

  @override
  Widget renderCover() {
    return Container(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
              tag: "menu${controller.menu.id}",
              child: Container(
                padding: EdgeInsets.only(top: 16.h),
                child: FutureBuilder<String?>(
                  initialData: SDUtils.getImgPath(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    return showImg(snapshot.data, 240, 240, radius: 24);
                  },
                  future:
                      AppUtils.getMusicCoverPath(controller.menu.music.first),
                ),
              ))
        ],
      ),
    );
  }
}
