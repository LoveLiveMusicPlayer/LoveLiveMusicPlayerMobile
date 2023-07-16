import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/page_view/keep_alive_wrapper.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_menu.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_album.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_singer.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_song_sheet.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';
import 'package:lovelivemusicplayer/widgets/refresher_widget.dart';

import 'logic.dart';

class PageViewComponent extends StatefulWidget {
  const PageViewComponent({Key? key}) : super(key: key);

  @override
  State<PageViewComponent> createState() => _PageViewComponentState();
}

class _PageViewComponentState extends State<PageViewComponent>
    with WidgetsBindingObserver {
  var controller1Offset = 0.0;
  var controller2Offset = 0.0;
  var controller3Offset = 0.0;
  var controller4Offset = 0.0;
  var controller5Offset = 0.0;
  var controller6Offset = 0.0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    HomeController.scrollController1.addListener(() {
      controller1Offset = HomeController.scrollController1.offset;
    });
    HomeController.scrollController2.addListener(() {
      controller2Offset = HomeController.scrollController2.offset;
    });
    HomeController.scrollController3.addListener(() {
      controller3Offset = HomeController.scrollController3.offset;
    });
    HomeController.scrollController4.addListener(() {
      controller4Offset = HomeController.scrollController4.offset;
    });
    HomeController.scrollController5.addListener(() {
      controller5Offset = HomeController.scrollController5.offset;
    });
    HomeController.scrollController6.addListener(() {
      controller6Offset = HomeController.scrollController6.offset;
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        checkAndJump(HomeController.scrollController1, controller1Offset);
        checkAndJump(HomeController.scrollController2, controller2Offset);
        checkAndJump(HomeController.scrollController3, controller3Offset);
        checkAndJump(HomeController.scrollController4, controller4Offset);
        checkAndJump(HomeController.scrollController5, controller5Offset);
        checkAndJump(HomeController.scrollController6, controller6Offset);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  checkAndJump(ScrollController controller, double offset) {
    if (controller.hasClients) {
      controller.jumpTo(offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(PageViewLogic());

    return Obx(() {
      return PageView(
        controller: logic.controller,
        physics: HomeController.to.state.isSelect.value
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        onPageChanged: (index) {
          HomeController.to.tabController?.animateTo(index > 2 ? 1 : 0);
          HomeController.to.state.currentIndex.value = index;
        },
        children: [
          KeepAliveWrapper(
              child: _buildList(0, HomeController.scrollController1)),
          KeepAliveWrapper(
              child: _buildList(1, HomeController.scrollController2)),
          KeepAliveWrapper(
              child: _buildList(2, HomeController.scrollController3)),
          KeepAliveWrapper(
              child: _buildList(3, HomeController.scrollController4)),
          KeepAliveWrapper(
              child: _buildList(4, HomeController.scrollController5)),
          KeepAliveWrapper(
              child: _buildList(5, HomeController.scrollController6))
        ],
      );
    });
  }

  Widget _buildList(int page, ScrollController scrollController) {
    final currentPage = HomeController.to.state.currentIndex.value;
    final hasPadding = currentPage == 1 || currentPage == 2 || currentPage == 4;
    return RefresherWidget(
      scrollController: scrollController,
      itemCount: GlobalLogic.to
          .getListSize(page, GlobalLogic.to.databaseInitOver.value),
      enablePullUp: false,
      enablePullDown: false,
      isGridView: page == 1,

      ///当前列表是否网格显示
      columnNum: 3,
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      leftPadding: hasPadding ? 16.w : 0,
      rightPadding: hasPadding ? 16.w : 0,
      aspectRatio: 0.9,
      listItem: (cxt, index) {
        return _buildListItem(index, page);
      },
    );
  }

  Widget _buildListItem(int index, int page) {
    /// 0 歌曲  1 专辑  2 歌手  3 我喜欢  4 歌单  5  最近播放
    if (page == 0) {
      return ListViewItemSong(
        index: index,
        music: GlobalLogic.to.musicList[index],
        checked: HomeController.to.isItemChecked(index),
        onItemTap: (index, checked) {
          HomeController.to.selectItem(index, checked);
        },
        onPlayNextTap: (music) async =>
            await PlayerLogic.to.addNextMusic(music),
        onMoreTap: (music) {
          SmartDialog.compatible.show(
              widget: DialogMoreWithMusic(music: music),
              alignmentTemp: Alignment.bottomCenter);
        },
        onPlayNowTap: () {
          PlayerLogic.to.playMusic(GlobalLogic.to.musicList, mIndex: index);
        },
      );
    } else if (page == 1) {
      return ListViewItemAlbum(
        album: GlobalLogic.to.albumList[index],
        checked: HomeController.to.isItemChecked(index),
        isSelect: HomeController.to.state.isSelect.value,
        onItemTap: (album, checked) {
          if (HomeController.to.state.isSelect.value) {
            HomeController.to.selectItem(index, checked);
          } else {
            Get.toNamed(Routes.routeAlbumDetails,
                arguments: GlobalLogic.to.albumList[index], id: 1);
          }
        },
      );
    } else if (page == 2) {
      return ListViewItemSinger(
        artist: GlobalLogic.to.artistList[index],
        onItemTap: (artist) {
          Get.toNamed(Routes.routeSingerDetails, arguments: artist, id: 1);
        },
      );
    } else if (page == 3) {
      return ListViewItemSong(
        index: index,
        music: GlobalLogic.to.loveList[index],
        checked: HomeController.to.isItemChecked(index),
        onItemTap: (index, checked) {
          HomeController.to.selectItem(index, checked);
        },
        onPlayNextTap: (music) async =>
            await PlayerLogic.to.addNextMusic(music),
        onMoreTap: (music) {
          SmartDialog.compatible.show(
              widget: DialogMoreWithMusic(music: music),
              alignmentTemp: Alignment.bottomCenter);
        },
        onPlayNowTap: () {
          PlayerLogic.to.playMusic(GlobalLogic.to.loveList, mIndex: index);
        },
      );
    } else if (page == 4) {
      return ListViewItemSongSheet(
        onItemTap: (menu) {
          Get.toNamed(Routes.routeMenuDetails, arguments: menu.id, id: 1);
        },
        onMoreTap: (menu) {
          SmartDialog.compatible.show(
              widget: DialogMoreWithMenu(menu: menu),
              alignmentTemp: Alignment.bottomCenter);
        },
        menu: GlobalLogic.to.menuList[index],
        showDevicePic: true,
      );
    } else {
      return ListViewItemSong(
        index: index,
        music: GlobalLogic.to.recentList[index],
        checked: HomeController.to.isItemChecked(index),
        onItemTap: (index, checked) {
          HomeController.to.selectItem(index, checked);
        },
        onPlayNextTap: (music) async =>
            await PlayerLogic.to.addNextMusic(music),
        onMoreTap: (music) {
          SmartDialog.compatible.show(
              widget: DialogMoreWithMusic(music: music),
              alignmentTemp: Alignment.bottomCenter);
        },
        onPlayNowTap: () {
          PlayerLogic.to.playMusic(GlobalLogic.to.recentList, mIndex: index);
        },
      );
    }
  }
}
