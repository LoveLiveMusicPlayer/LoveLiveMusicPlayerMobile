import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

class BottomBar2 extends StatelessWidget {
  const BottomBar2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mIndex = handlePage(HomeController.to.state.currentIndex.value);
      final colorFilter1 = ColorFilter.mode(
          mIndex == 0 ? ColorMs.colorF940A7 : ColorMs.colorD1E0F3,
          BlendMode.srcIn);
      final colorFilter2 = ColorFilter.mode(
          mIndex == 1 ? ColorMs.colorF940A7 : ColorMs.colorD1E0F3,
          BlendMode.srcIn);
      final colorFilter3 = ColorFilter.mode(
          mIndex == 2 ? ColorMs.colorF940A7 : ColorMs.colorD1E0F3,
          BlendMode.srcIn);
      return BottomNavigationBar(
        showUnselectedLabels: true,
        currentIndex: mIndex,
        selectedFontSize: 10.sp,
        unselectedFontSize: 10.sp,
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabLove,
                  height: 18.h, width: 18.h, colorFilter: colorFilter1),
              label: 'iLove'.tr),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabPlaylist,
                  height: 18.h, width: 18.h, colorFilter: colorFilter2),
              label: 'songMenu'.tr),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabRecently,
                  height: 18.h, width: 18.h, colorFilter: colorFilter3),
              label: 'history'.tr),
        ],
        elevation: 0,
        backgroundColor: GlobalLogic.to.bgPhoto.value == ""
            ? GlobalLogic.to
                .getThemeColor(ColorMs.color4E4E4E, ColorMs.colorFAFAFA)
            : Colors.transparent,
        selectedItemColor: ColorMs.colorD91F86,
        unselectedItemColor: ColorMs.colorA9B9CD.withOpacity(0.5),
        onTap: (index) {
          if (HomeController.to.state.currentIndex.value == index + 3) {
            switch (index + 3) {
              case 3:
                scrollTo(HomeController.scrollController4);
                break;
              case 4:
                scrollTo(HomeController.scrollController5);
                break;
              case 5:
                scrollTo(HomeController.scrollController6);
                break;
            }
          }
          PageViewLogic.to.controller.jumpToPage(index + 3);
        },
      );
    });
  }

  scrollTo(ScrollController controller) {
    try {
      controller.animateTo(0,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  int handlePage(int index) {
    return index % 3;
  }
}
