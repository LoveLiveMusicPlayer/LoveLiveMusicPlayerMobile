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
    final coverPath = controller.menu.coverPath;
    if (coverPath == null) {
      return Container(
        padding: EdgeInsets.only(top: 16.h),
        child: FutureBuilder<String?>(
          initialData: SDUtils.getImgPath(),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            final image = showImg(snapshot.data, 240, 240);
            if (snapshot.connectionState == ConnectionState.done) {
              return Hero(tag: "menu${controller.menu.id}", child: image);
            }
            return image;
          },
          future: AppUtils.getMusicCoverPath(controller.menu.music.first),
        ),
      );
    } else {
      final image = showImg(coverPath, 240, 240);
      return Hero(tag: "menu${controller.menu.id}", child: image);
    }
  }
}
