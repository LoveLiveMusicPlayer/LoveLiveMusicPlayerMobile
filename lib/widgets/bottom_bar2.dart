import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';

class BottomBar2 extends StatelessWidget {
  const BottomBar2({Key? key}) : super(key: key);

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
              icon: SvgPicture.asset(Assets.tabTabLove,
                  height: 18.h,
                  width: 20.h,
                  color: mIndex == 0
                      ? const Color(0xFFF940A7)
                      : const Color(0xFFD1E0F3)),
              label: '我喜欢'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabPlaylist,
                  height: 18.h,
                  width: 20.h,
                  color: mIndex == 1
                      ? const Color(0xFFF940A7)
                      : const Color(0xFFD1E0F3)),
              label: '歌单'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(Assets.tabTabRecently,
                  height: 18.h,
                  width: 20.h,
                  color: mIndex == 2
                      ? const Color(0xFFF940A7)
                      : const Color(0xFFD1E0F3)),
              label: '最近播放'),
        ],
        elevation: 0,
        backgroundColor: colorTheme.surface,
        selectedFontSize: 13.sp,
        unselectedFontSize: 13.sp,
        selectedItemColor: const Color(0xFFD91F86),
        unselectedItemColor: const Color(0xFFA9B9CD).withOpacity(0.5),
        onTap: (index) {
          if (HomeController.to.state.currentIndex.value == index + 3) {
            switch (index + 3) {
              case 3:
                scrollTo(HomeController.to.scrollController4);
                break;
              case 4:
                scrollTo(HomeController.to.scrollController5);
                break;
              case 5:
                scrollTo(HomeController.to.scrollController6);
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
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  int handlePage(int index) {
    return index % 3;
  }
}
