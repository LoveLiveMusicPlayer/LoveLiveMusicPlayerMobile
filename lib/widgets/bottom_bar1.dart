import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = Get.theme.colorScheme;

    return Obx(() {
      final mIndex = handlePage(HomeController.to.state.currentIndex.value);
      return BottomNavigationBar(
        showUnselectedLabels: true,
        currentIndex: mIndex,
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabMusic,
                  height: 18.h,
                  width: 20.h,
                  color: mIndex == 0
                      ? const Color(0xFFF940A7)
                      : const Color(0xFFD1E0F3)),
              label: '歌曲'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabAlbum,
                  height: 18.h,
                  width: 20.h,
                  color: mIndex == 1
                      ? const Color(0xFFF940A7)
                      : const Color(0xFFD1E0F3)),
              label: '专辑'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabSinger,
                  height: 18.h,
                  width: 20.h,
                  color: mIndex == 2
                      ? const Color(0xFFF940A7)
                      : const Color(0xFFD1E0F3)),
              label: '歌手'),
        ],
        elevation: 0,
        backgroundColor: colorTheme.surface,
        selectedItemColor: const Color(0xFFF940A7),
        unselectedItemColor: const Color(0xFFD1E0F3),
        onTap: (index) {
          if (HomeController.to.state.currentIndex.value == index) {
            switch (index) {
              case 0:
                scrollTo(HomeController.to.scrollController1);
                break;
              case 1:
                scrollTo(HomeController.to.scrollController2);
                break;
              case 2:
                scrollTo(HomeController.to.scrollController3);
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
    } catch (e) {}
  }

  int handlePage(int index) {
    return index % 3;
  }
}
