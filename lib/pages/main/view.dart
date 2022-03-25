import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_slide/we_slide.dart';
import '../../models/music_Item.dart';
import '../../utils/sd_utils.dart';
import '../../widgets/refresher_widget.dart';
import '../player/bottom_bar.dart';
import '../player/miniplayer.dart';
import '../player/player.dart';
import 'widget/listview_item.dart';
import 'widget/song_library_top.dart';
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
    return Container(
      color: const Color(0xFFF2F8FF),
      child: Column(
        children: [
          AppBar(
            toolbarHeight: 54.w,
            elevation: 0,
            backgroundColor: const Color(0xFFF2F8FF),
            title: _getTabBar(),
            actions: [_getTopHead()],
          ),
          Expanded(child: _buildWeSlide(context)),
        ],
      ),
    );
    // return Scaffold(
    //   backgroundColor: const Color(0xFFF2F8FF),
    //   appBar: AppBar(
    //     toolbarHeight: 54.w,
    //     elevation: 0,
    //     backgroundColor: const Color(0xFFF2F8FF),
    //     title: _getTabBar(),
    //     actions: [_getTopHead()],
    //   ),
    //   body: _buildWeSlide(context),
    // );
  }




  Widget _buildWeSlide(BuildContext context) {
    final WeSlideController _controller = WeSlideController();
    const double _panelMinSize = 150;
    final double _panelMaxSize = ScreenUtil().screenHeight;
    final colorTheme = Theme.of(context).colorScheme;
    return WeSlide(
      controller: _controller,
      panelMinSize: _panelMinSize.h,
      panelMaxSize: _panelMaxSize,
      overlayOpacity: 0.9,
      backgroundColor: const Color(0xFFF2F8FF),
      overlay: true,
      isDismissible: true,
      body: _getTabBarView(),
      blurColor: const Color(0xFFF2F8FF),
      overlayColor: const Color(0xFFF2F8FF),
      panelHeader: MiniPlayer(
          onTap: _controller.show,
          onChangeMusic: (index, reason) => {logic.playingIndex.value = index}),
      panel: Player(onTap: _controller.hide),
      footer: Obx(() {
        return _buildTabBarView();
      }),
      footerHeight: 84.h,
      blur: true,
      parallax: true,
      transformScale: true,
      blurSigma: 5.0,
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

  Widget _getTabBarView() {
    return Column(
      children: [
        ///顶部歌曲总数栏
        _buildListTop(),

        ///列表数据
        _buildList(),

        ///底部滑动导航
        // _buildTabBarView()
      ],
    );
  }

  ///顶部歌曲总数栏
  Widget _buildListTop() {
    return Song_libraryTop(
      onPlayTap: () {},
      onScreenTap: () {
        logic.openSelect();
      },
      onSelectAllTap: (checked) {
        logic.selectAll(checked);
      },
      onCancelTap: () {
        logic.openSelect();
      },
    );
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  Widget _buildList() {
    return Expanded(
      child: GetBuilder<MainLogic>(builder: (logic) {
        return RefresherWidget(
          itemCount: logic.state.items.length,
          enablePullDown: logic.state.items.isNotEmpty,
          listItem: (cxt, index) {
            print(index);
            return ListViewItem(
              index: index,
              onItemTap: (valut) {},
              onPlayTap: () {},
              onMoreTap: () {},
            );
          },
          onRefresh: (controller) async {
            await Future.delayed(const Duration(milliseconds: 1000));
            logic.state.items.clear();

            logic.addItem([
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false)
            ]);
            controller.refreshCompleted();
            controller.loadComplete();
          },
          onLoading: (controller) async {
            await Future.delayed(const Duration(milliseconds: 1000));
            logic.addItem([
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false)
            ]);
            controller.loadComplete();
          },
        );
      }),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      children: [
        BottomBar(logic.currentIndex.value, onSelect: (index) {
          logic.currentIndex.value = index;
        }),
        BottomBar(logic.currentIndex.value, onSelect: (index) {
          logic.currentIndex.value = index;
        }),
      ],
      controller: tabController,
    );
  }
}
