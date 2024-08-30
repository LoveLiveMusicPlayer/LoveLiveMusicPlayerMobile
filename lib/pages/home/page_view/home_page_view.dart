import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/modules/pageview/view.dart';
import 'package:lovelivemusicplayer/modules/tabbar/tabbar.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/song_library_top.dart';

class HomePageView extends GetView<HomeController> {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(child: _getTabBarView(() {
      if (HomeController.to.state.selectMode.value == 0) {
        GlobalLogic.to.globalKey.currentState?.openEndDrawer();
      }
    }));
  }

  Widget _getTabBarView(GestureTapCallback? onTap) {
    return Column(
      children: [
        AppBar(
          toolbarHeight: 60.h,
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _getTabBar(),
          systemOverlayStyle: GlobalLogic.to.isDarkTheme.value
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          actions: [_getTopHead(onTap)],
        ),
        _buildListTop(),
        const Expanded(child: PageViewComponent())
      ],
    );
  }

  Widget _getTabBar() {
    return Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: Obx(() {
          return HomeController.to.state.selectMode.value > 0
              ? const IgnorePointer(child: TabBarComponent())
              : const TabBarComponent();
        }));
  }

  ///顶部头像
  Widget _getTopHead(GestureTapCallback? onTap) {
    return Obx(() {
      final photoPath =
          GlobalLogic.to.getCurrentGroupIcon(GlobalLogic.to.currentGroup.value);
      final padding = EdgeInsets.all(photoPath == Assets.logoLogo ? 3.w : 0);
      final bgColor = photoPath == Assets.logoLogo
          ? const Color(Const.noMusicColorfulSkin)
          : Get.theme.primaryColor;
      return neumorphicButton(photoPath, onTap,
          width: 36,
          height: 36,
          radius: 18,
          bgColor: bgColor,
          padding: padding,
          shadowColor: bgColor,
          margin: EdgeInsets.only(right: 16.w));
    });
  }

  ///顶部歌曲总数栏
  Widget _buildListTop() {
    return SongLibraryTop(
      onPlayTap: controller.onPlayTap,
      onScreenTap: controller.openSelect,
      onSelectAllTap: controller.selectAll,
      onCancelTap: SmartDialog.dismiss,
      onSearchTap: controller.filterItem,
      onSortTap: controller.sortItem,
    );
  }
}
