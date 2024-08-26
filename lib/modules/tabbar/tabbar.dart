import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/custom_underline_tab_indicator.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

class TabBarComponent extends StatelessWidget {
  const TabBarComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabAlignment: TabAlignment.start,
      physics: const NeverScrollableScrollPhysics(),
      onTap: (index) {
        PageViewLogic.to.pageController.jumpToPage(
            index * 3 + HomeController.to.state.currentIndex.value % 3);
      },
      indicatorWeight: 4.w,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: ColorMs.colorF940A7,
      dividerHeight: 0,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      // 设置点击效果的颜色为透明
      labelPadding: EdgeInsets.only(left: 4.w, right: 4.w),
      indicator: CustomUnderlineTabIndicator(
          insets: EdgeInsets.only(top: 0, bottom: 8.h),
          borderSide: BorderSide(width: 16.w, color: ColorMs.colorF940A7),
          indicatorWeight: 4.w),
      isScrollable: true,
      labelColor: ColorMs.colorF940A7,
      unselectedLabelColor: ColorMs.colorA9B9CD,
      labelStyle: TextStyle(
          fontSize: 20.h, fontWeight: FontWeight.bold, fontFamily: 'KaTong'),
      unselectedLabelStyle: TextStyle(
          fontSize: 16.h, fontWeight: FontWeight.bold, fontFamily: 'KaTong'),
      tabs: [
        Tab(text: 'song_lib'.tr),
        Tab(text: 'mine'.tr),
      ],
      controller: HomeController.to.tabController,
    );
  }
}
