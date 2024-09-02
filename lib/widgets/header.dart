import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class AppHeader extends GetView {
  final String title;
  final Function()? onBack;

  const AppHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Column(children: [
          SizedBox(height: MediaQuery.of(Get.context!).padding.top + 14.56.h),
          Stack(alignment: Alignment.center, children: [
            Row(children: [
              neumorphicButton(Icons.arrow_back_ios_rounded, () {
                if (onBack == null) {
                  HomeController.to.state.selectMode.value = 0;
                  SmartDialog.dismiss();
                  NestedController.to.fromGestureBack = false;
                  NestedController.to.goBack(fromBtnBack: true);
                } else {
                  onBack!();
                }
              }, margin: EdgeInsets.only(left: 16.w))
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
  }
}
