import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class DetailsHeader extends StatelessWidget {
  final String title;
  final Function()? onBack;

  const DetailsHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GlobalLogic>(builder: (logic) {
      final hasShadow = logic.bgPhoto.value == "";
      return Container(
          color: logic.bgPhoto.value == ""
              ? Get.theme.primaryColor
              : Colors.transparent,
          child: Column(children: [
            SizedBox(height: MediaQuery.of(Get.context!).padding.top + 14.56.h),
            Stack(alignment: Alignment.center, children: [
              Row(children: [
                Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: materialButton(Icons.keyboard_arrow_left, () {
                      if (onBack == null) {
                        HomeController.to.state.selectMode.value = 0;
                        SmartDialog.dismiss();
                        NestedController.to.fromGestureBack = false;
                        NestedController.to.goBack(fromBtnBack: true);
                      } else {
                        onBack!();
                      }
                    },
                        width: 32,
                        height: 32,
                        iconSize: 24,
                        radius: 6,
                        hasShadow: hasShadow))
              ]),
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Get.width - 120.w),
                  child: Text(title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style:
                          (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
                              ? TextStyleMs.white_15
                              : TextStyleMs.black_15))
            ])
          ]));
    });
  }
}
