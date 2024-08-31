import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/log.dart';

abstract class BottomBar extends GetView<HomeController> {
  final int mPage;

  const BottomBar(this.mPage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mIndex = handlePage(controller.state.currentIndex.value);
      return BottomNavigationBar(
        showUnselectedLabels: true,
        currentIndex: mIndex,
        selectedFontSize: 10.sp,
        unselectedFontSize: 10.sp,
        items: renderBottomNavigationBarItemList(mIndex),
        elevation: 0,
        backgroundColor: GlobalLogic.to.bgPhoto.value == ""
            ? GlobalLogic.to
                .getThemeColor(ColorMs.color4E4E4E, ColorMs.colorFAFAFA)
            : Colors.transparent,
        selectedItemColor: ColorMs.colorD91F86,
        unselectedItemColor: ColorMs.colorA9B9CD.withOpacity(0.5),
        onTap: onTap,
      );
    });
  }

  List<BottomNavigationBarItem> renderBottomNavigationBarItemList(int cIndex);

  BottomNavigationBarItem bottomBar(
      String iconPath, bool isChoice, String label) {
    return BottomNavigationBarItem(
        icon: Column(
          children: [
            SvgPicture.asset(iconPath,
                height: 18.h,
                width: 18.h,
                colorFilter: ColorFilter.mode(
                    isChoice ? ColorMs.colorF940A7 : ColorMs.colorD1E0F3,
                    BlendMode.srcIn)),
            SizedBox(height: 5.h)
          ],
        ),
        label: label);
  }

  onTap(int index) {
    if (controller.state.selectMode.value > 0) {
      return;
    }
    final currentIndex = mPage == 1 ? index : index + 3;
    if (controller.state.currentIndex.value == currentIndex) {
      scrollTo(HomeController.scrollControllers[currentIndex]);
    }
    PageViewLogic.to.pageController.jumpToPage(currentIndex);
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
