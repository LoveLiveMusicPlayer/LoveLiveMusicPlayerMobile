import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/sd_utils.dart';
import '../my/view.dart';
import '../song_library/view.dart';
import 'logic.dart';
import 'widget/custom_underline_tabIndicator.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final logic = Get.put(MainLogic());
  final state = Get.find<MainLogic>().state;
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      appBar: AppBar(
        toolbarHeight: 54.w,
        elevation: 0,
        backgroundColor: const Color(0xFFF2F8FF),
        title: _getTabBar(),
        actions: [_getTopHead()],
      ),
      body: _getTabBarView(),
    );
  }

  Widget _getTabBar() {
    return TabBar(
      indicatorWeight: 4.w,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: const Color(0xFFF940A7),
      labelPadding: EdgeInsets.only(left: 4.w, right: 4.w),
      indicator: CustomUnderlineTabIndicator(
          insets: EdgeInsets.only(top: 0.w, bottom: 4.w),
          borderSide: BorderSide(width: 16.w, color: Colors.red),
          indicatorWeight: 4.w),
      isScrollable: true,
      labelColor: const Color(0xFFF940A7),
      unselectedLabelColor: const Color(0xFFA9B9CD),
      labelStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
      unselectedLabelStyle:
          TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      tabs: const [
        Tab(
          text: "歌库",
        ),
        Tab(
          text: "我的",
        ),
      ],
      controller: tabController,
    );
  }

  Widget _getTabBarView() {
    return TabBarView(
      children: [
        Song_libraryPage(),
        MyPage(),
      ],
      controller: tabController,
    );
  }

  ///顶部头像
  Widget _getTopHead() {
    return Container(
      child: Center(
        child: Container(
          margin: EdgeInsets.only(right: 16.w),
          height: 36.w,
          width: 36.w,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.w),
              boxShadow: [
                BoxShadow(
                    color: Color(0xffcccccc),
                    spreadRadius: 0.1,
                    offset: Offset.fromDirection(18.w, -5.w),
                    blurRadius: 10)
              ]),
          child: CircleAvatar(
            radius: 18.w,
            backgroundImage: FileImage(SdUtils.getImgFile("ic_head.jpg")),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }
}
