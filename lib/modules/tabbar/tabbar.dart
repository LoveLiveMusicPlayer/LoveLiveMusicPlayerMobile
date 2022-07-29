import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/custom_underline_tabIndicator.dart';

class TabBarComponent extends StatelessWidget {
  const TabBarComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      physics: const NeverScrollableScrollPhysics(),
      onTap: (index) {
        PageViewLogic.to.controller
            .jumpToPage(HomeController.to.state.currentIndex.value);
      },
      indicatorWeight: 4.w,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: const Color(0xFFF940A7),
      labelPadding: EdgeInsets.only(left: 4.w, right: 4.w),
      indicator: CustomUnderlineTabIndicator(
          insets: EdgeInsets.only(top: 0.w, bottom: 8.h),
          borderSide: BorderSide(width: 16.w, color: const Color(0xFFF940A7)),
          indicatorWeight: 4.w),
      isScrollable: true,
      labelColor: const Color(0xFFF940A7),
      unselectedLabelColor: const Color(0xFFA9B9CD),
      labelStyle: TextStyle(
          fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: 'KaTong'),
      unselectedLabelStyle: TextStyle(
          fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'KaTong'),
      tabs: const [
        Tab(text: "歌库"),
        Tab(text: "我的"),
      ],
      controller: HomeController.to.tabController,
    );
  }
}
