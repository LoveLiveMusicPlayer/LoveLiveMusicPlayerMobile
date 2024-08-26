import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/log.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

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
              icon: SvgPicture.asset(Assets.tabTabMusic,
                  height: 18.h, width: 18.h, colorFilter: colorFilter1),
              label: 'music'.tr),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabAlbum,
                  height: 18.h, width: 18.h, colorFilter: colorFilter2),
              label: 'album'.tr),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabSinger,
                  height: 18.h, width: 18.h, colorFilter: colorFilter3),
              label: 'singer'.tr),
        ],
        elevation: 0,
        backgroundColor: GlobalLogic.to.bgPhoto.value == ""
            ? GlobalLogic.to
                .getThemeColor(ColorMs.color4E4E4E, ColorMs.colorFAFAFA)
            : Colors.transparent,
        selectedItemColor: ColorMs.colorF940A7,
        unselectedItemColor: ColorMs.colorD1E0F3,
        onTap: (index) {
          if (HomeController.to.state.selectMode.value > 0) {
            return;
          }
          if (HomeController.to.state.currentIndex.value == index) {
            scrollTo(HomeController.scrollControllers[index]);
          }
          PageViewLogic.to.pageController.jumpToPage(index);
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
