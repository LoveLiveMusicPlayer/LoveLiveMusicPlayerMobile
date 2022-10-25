import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mIndex = handlePage(HomeController.to.state.currentIndex.value);
      return BottomNavigationBar(
        showUnselectedLabels: true,
        currentIndex: mIndex,
        selectedFontSize: 10.sp,
        unselectedFontSize: 10.sp,
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabMusic,
                  height: 18.h,
                  width: 18.h,
                  color:
                      mIndex == 0 ? ColorMs.colorF940A7 : ColorMs.colorD1E0F3),
              label: 'music'.tr),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabAlbum,
                  height: 18.h,
                  width: 18.h,
                  color:
                      mIndex == 1 ? ColorMs.colorF940A7 : ColorMs.colorD1E0F3),
              label: 'album'.tr),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabSinger,
                  height: 18.h,
                  width: 18.h,
                  color:
                      mIndex == 2 ? ColorMs.colorF940A7 : ColorMs.colorD1E0F3),
              label: 'singer'.tr),
        ],
        elevation: 0,
        // backgroundColor: Colors.transparent,
        backgroundColor: GlobalLogic.to
            .getThemeColor(ColorMs.color4E4E4E, ColorMs.colorFAFAFA),
        selectedItemColor: ColorMs.colorF940A7,
        unselectedItemColor: ColorMs.colorD1E0F3,
        onTap: (index) {
          if (HomeController.to.state.currentIndex.value == index) {
            switch (index) {
              case 0:
                scrollTo(HomeController.scrollController1);
                break;
              case 1:
                scrollTo(HomeController.scrollController2);
                break;
              case 2:
                scrollTo(HomeController.scrollController3);
                break;
            }
          }
          PageViewLogic.to.controller.jumpToPage(index);
        },
      );
    });
  }

  scrollTo(ScrollController controller) {
    try {
      controller.animateTo(0,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  int handlePage(int index) {
    return index % 3;
  }
}
