import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/drawer/drawer.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/modules/pageview/view.dart';
import 'package:lovelivemusicplayer/modules/tabbar/tabbar.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/player/miniplayer.dart';
import 'package:lovelivemusicplayer/pages/player/player.dart';
import 'package:lovelivemusicplayer/utils/android_back_desktop.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar1.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar2.dart';
import 'package:we_slide/we_slide.dart';

import 'widget/song_library_top.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final logic = Get.find<HomeController>();
  WeSlideController? controller;

  @override
  void initState() {
    super.initState();
    logic.tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller?.removeListener(addListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressTime;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return WillPopScope(
        child: Scaffold(
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            endDrawer: SizedBox(
              width: 300.w,
              child: const DrawerPage(),
            ),
            body: _weSlider(scaffoldKey)),
        onWillPop: () async {
          if (lastPressTime == null ||
              DateTime.now().difference(lastPressTime!) >
                  const Duration(seconds: 1)) {
            //间隔时间大于1秒 则重新赋值
            lastPressTime = DateTime.now();
            SmartDialog.compatible.showToast("再次点击回到桌面");
            return false;
          }
          AndroidBackDesktop.backToDesktop();
          return false;
        });
  }

  Widget _weSlider(GlobalKey<ScaffoldState> scaffoldKey) {
    controller = WeSlideController();
    const double panelMinSize = 150;
    final double panelMaxSize = ScreenUtil().screenHeight;

    return WeSlide(
      controller: controller,
      panelMinSize: panelMinSize.h,
      panelMaxSize: panelMaxSize,
      overlayOpacity: 0.9,
      backgroundColor: Theme.of(context).primaryColor,
      overlay: true,
      isDismissible: true,
      body: _getTabBarView(() {
        if (!HomeController.to.state.isSelect.value) {
          scaffoldKey.currentState?.openEndDrawer();
        }
      }),
      blurColor: Theme.of(context).primaryColor,
      overlayColor: Theme.of(context).primaryColor,
      panelBorderRadiusBegin: 10,
      panelBorderRadiusEnd: 10,
      panelHeader: MiniPlayer(onTap: () {
        if (!HomeController.to.state.isSelect.value) {
          if (addListener() == null) {
            controller?.addListener(addListener);
          }
          controller?.show();
        }
      }),
      panel: Player(onTap: () => controller?.hide()),
      footer: _buildTabBarView(),
      footerHeight: 84.h,
      blur: true,
      parallax: true,
      isUpSlide: false,
      transformScale: true,
      blurSigma: 5.0,
      fadeSequence: [
        TweenSequenceItem<double>(weight: 1.0, tween: Tween(begin: 1, end: 0)),
        TweenSequenceItem<double>(weight: 8.0, tween: Tween(begin: 0, end: 0)),
      ],
    );
  }

  Widget _getTabBar() {
    return Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: Obx(() {
          final isSelect = HomeController.to.state.isSelect.value;
          return isSelect
              ? const IgnorePointer(
                  child: TabBarComponent(),
                )
              : const TabBarComponent();
        }));
  }

  ///顶部头像
  Widget _getTopHead(GestureTapCallback? onTap) {
    return Obx(() {
      return logoIcon(
          GlobalLogic.to.getCurrentGroupIcon(GlobalLogic.to.currentGroup.value),
          offset: EdgeInsets.only(right: 16.w),
          onTap: onTap);
    });
  }

  Widget _getTabBarView(GestureTapCallback? onTap) {
    return Column(
      children: [
        AppBar(
          toolbarHeight: 60.h,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: Get.theme.primaryColor,
          title: _getTabBar(),
          actions: [_getTopHead(onTap)],
        ),
        _buildListTop(),
        const Expanded(child: PageViewComponent())
      ],
    );
  }

  ///顶部歌曲总数栏
  Widget _buildListTop() {
    return SongLibraryTop(
      onPlayTap: () {
        PlayerLogic.to.playMusic(GlobalLogic.to
            .filterMusicListByAlbums(logic.state.currentIndex.value));
      },
      onScreenTap: () {
        logic.openSelect();
        showSelectDialog();
      },
      onSelectAllTap: (checked) {
        logic.selectAll(checked);
      },
      onCancelTap: () {
        logic.closeSelect();
        SmartDialog.dismiss();
      },
    );
  }

  addListener() {
    eventBus.fire(PlayerClosableEvent(controller?.isOpened ?? false));
  }

  showSelectDialog() {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList2,
        title: "加入播放列表",
        onTap: () async {
          List<Music> musicList = HomeController.to.state.items.cast();
          List<Music> tempList = [];
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              tempList.add(music);
            }
          });
          PlayerLogic.to.addMusicList(tempList);
          SmartDialog.showToast("添加成功");
        }));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList,
        title: "添加到歌单",
        onTap: () async {
          SmartDialog.dismiss();
          List<Music> musicList = HomeController.to.state.items.cast();
          List<Music> tempList = [];
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              tempList.add(music);
            }
          });
          SmartDialog.compatible.show(
              widget: DialogAddSongSheet(musicList: tempList),
              alignmentTemp: Alignment.bottomCenter);
        }));
    SmartDialog.compatible.show(
        widget: DialogBottomBtn(
          list: list,
        ),
        isPenetrateTemp: true,
        clickBgDismissTemp: false,
        maskColorTemp: Colors.transparent,
        alignmentTemp: Alignment.bottomCenter,
        onDismiss: () => logic.closeSelect());
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: logic.tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: const [BottomBar(), BottomBar2()],
    );
  }
}
