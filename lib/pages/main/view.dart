import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/main/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/main/widget/dialog_more.dart';
import 'package:lovelivemusicplayer/pages/main/widget/listview_item_album.dart';
import 'package:lovelivemusicplayer/pages/main/widget/listview_item_singer.dart';
import 'package:lovelivemusicplayer/pages/main/widget/listview_item_song_sheet.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:we_slide/we_slide.dart';
import '../../modules/drawer/drawer.dart';
import '../../widgets/refresher_widget.dart';
import '../player/miniplayer.dart';
import '../player/player.dart';
import '../player/widget/bottom_bar1.dart';
import '../player/widget/bottom_bar2.dart';
import '../../widgets/listview_item_song.dart';
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
  final global = Get.find<GlobalLogic>();
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final WeSlideController _controller = WeSlideController();
    const double _panelMinSize = 150;
    final double _panelMaxSize = ScreenUtil().screenHeight;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const DrawerPage(),
      body: WeSlide(
        controller: _controller,
        panelMinSize: _panelMinSize.h,
        panelMaxSize: _panelMaxSize,
        overlayOpacity: 0.9,
        backgroundColor: Theme.of(context).primaryColor,
        overlay: true,
        isDismissible: true,
        body: _getTabBarView(() => _scaffoldKey.currentState?.openEndDrawer()),
        blurColor: Theme.of(context).primaryColor,
        overlayColor: Theme.of(context).primaryColor,
        panelBorderRadiusBegin: 10,
        panelBorderRadiusEnd: 10,
        panelHeader: MiniPlayer(onTap: _controller.show),
        panel: Player(onTap: _controller.hide),
        footer: _buildTabBarView(),
        footerHeight: 84.h,
        blur: true,
        parallax: true,
        isUpSlide: false,
        transformScale: true,
        blurSigma: 5.0,
        fadeSequence: [
          TweenSequenceItem<double>(
              weight: 1.0, tween: Tween(begin: 1, end: 0)),
          TweenSequenceItem<double>(
              weight: 8.0, tween: Tween(begin: 0, end: 0)),
        ],
      ),
    );
  }

  Widget _getTabBar() {
    return Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: TabBar(
          onTap: (index) => logic.changeTab(index),
          indicatorWeight: 4.w,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: const Color(0xFFF940A7),
          labelPadding: EdgeInsets.only(left: 4.w, right: 4.w),
          indicator: CustomUnderlineTabIndicator(
              insets: EdgeInsets.only(top: 0.w, bottom: 8.h),
              borderSide:
                  BorderSide(width: 16.w, color: const Color(0xFFF940A7)),
              indicatorWeight: 4.w),
          isScrollable: true,
          labelColor: const Color(0xFFF940A7),
          unselectedLabelColor: const Color(0xFFA9B9CD),
          labelStyle: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'KaTong'),
          unselectedLabelStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'KaTong'),
          tabs: const [
            Tab(text: "歌库"),
            Tab(text: "我的"),
          ],
          controller: tabController,
        ));
  }

  ///顶部头像
  Widget _getTopHead(GestureTapCallback onTap) {
    return logoIcon("ic_head.jpg",
        offset: EdgeInsets.only(right: 16.w), onTap: onTap);
  }

  Widget _getTabBarView(GestureTapCallback onTap) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 54.w,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(Get.context!).primaryColor,
        title: _getTabBar(),
        actions: [_getTopHead(onTap)],
      ),
      body: Column(
        children: [
          ///顶部歌曲总数栏
          _buildListTop(),

          ///列表数据
          _buildList(),
        ],
      ),
    );
  }

  ///顶部歌曲总数栏
  Widget _buildListTop() {
    return Song_libraryTop(
      onPlayTap: () {
        LogUtil.e(global.musicByAllList.length);
      },
      onScreenTap: () {
        logic.openSelect();
        showSelectDialog();
      },
      onSelectAllTap: (checked) {
        logic.selectAll(checked);
      },
      onCancelTap: () {
        logic.openSelect();
        SmartDialog.dismiss();
      },
    );
  }

  showSelectDialog() {
    List<BtnItem> list = [];
    if (logic.state.currentIndex == 1) {
      list.add(BtnItem(
          imgPath: "assets/dialog/ic_add_play_list2.svg",
          title: "专辑播放",
          onTap: () {}));
      list.add(BtnItem(
          imgPath: "assets/dialog/ic_add_song_sheet.svg",
          title: "添加到歌单",
          onTap: () {}));
      list.add(BtnItem(
          imgPath: "assets/dialog/ic_delete.svg", title: "删除专辑", onTap: () {}));
    } else if (logic.state.currentIndex == 1) {
      list.add(BtnItem(
          imgPath: "assets/dialog/ic_add_play_list2.svg",
          title: "全部播放",
          onTap: () {}));
      list.add(BtnItem(
          imgPath: "assets/dialog/ic_add_play_list.svg",
          title: "添加到歌单",
          onTap: () {}));
    } else {
      list.add(BtnItem(
          imgPath: "assets/dialog/ic_add_play_list2.svg",
          title: "加入播放列表",
          onTap: () {}));
      list.add(BtnItem(
          imgPath: "assets/dialog/ic_add_play_list.svg",
          title: "添加到歌单",
          onTap: () {}));
    }
    SmartDialog.show(
        widget: DialogBottomBtn(
          list: list,
        ),
        isPenetrateTemp: true,
        clickBgDismissTemp: false,
        maskColorTemp: Colors.transparent,
        alignmentTemp: Alignment.bottomCenter);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  Widget _buildList() {
    return Expanded(
      child: GetBuilder<MainLogic>(builder: (logic) {
        return RefresherWidget(
          itemCount: global.getListSize(logic.state.currentIndex),
          enablePullUp: false,
          enablePullDown: false,
          isGridView: logic.state.currentIndex == 1,

          ///当前列表是否网格显示
          columnNum: 3,
          crossAxisSpacing: 20.h,
          mainAxisSpacing: 20.h,
          leftPadding: 16.h,
          rightPadding: 16.h,
          aspectRatio: 0.715,
          listItem: (cxt, index) {
            return _buildListItem(logic, index);
          },
        );
      }),
    );
  }

  Widget _buildListItem(MainLogic logic, int index) {
    /// 0 歌曲  1 专辑  2 歌手  3 我喜欢  4 歌单  5  最近播放
    if (logic.state.currentIndex == 1) {
      return ListViewItemAlbum(
        album: global.checkAlbumList()[index],
        checked: logic.isItemChecked(index),
        isSelect: logic.state.isSelect,
        onItemTap: (album, checked) {
          LogUtil.e(index);
          if (logic.state.isSelect) {
            logic.selectItem(album, checked);
          } else {
            Get.toNamed(Routes.routeAlbumDetails, arguments: global.checkAlbumList()[index]);
          }
        },
      );
    } else if (logic.state.currentIndex == 2) {
      return ListViewItemSinger(
        index: index,
        checked: logic.isItemChecked(index),
        isSelect: logic.state.isSelect,
        onItemTap: (artist, checked) {
          if (logic.state.isSelect) {
            logic.selectItem(artist, checked);
          } else {
            Get.toNamed(Routes.routeSingerDetails, arguments: global.checkAlbumList()[index]);
          }
        },
      );
    } else if (logic.state.currentIndex == 4) {
      return ListViewItemSongSheet(onItemTap: (checked) {}, index: index);
    } else {
      return ListViewItemSong(
        music: global.checkMusicList()[index],
        checked: logic.isItemChecked(index),
        isSelect: logic.state.isSelect,
        onItemTap: (music, checked) {
          logic.selectItem(music, checked);
        },
        onPlayTap: (index) {},
        onMoreTap: (index) {
          SmartDialog.show(
              widget: DialogMore(), alignmentTemp: Alignment.bottomCenter);
        },
      );
    }
  }

  Widget _buildTabBarView() {
    return TabBarView(
      children: const [
        BottomBar(),
        BottomBar2(),
      ],
      controller: tabController,
    );
  }
}
