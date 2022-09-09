import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_menu.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_album.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_singer.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_song_sheet.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_love.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';
import 'package:lovelivemusicplayer/widgets/refresher_widget.dart';

import 'logic.dart';

class PageViewComponent extends StatelessWidget {
  const PageViewComponent({Key? key}) : super(key: key);

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
          _buildList(0, HomeController.to.scrollController1),
          _buildList(1, HomeController.to.scrollController2),
          _buildList(2, HomeController.to.scrollController3),
          _buildList(3, HomeController.to.scrollController4),
          _buildList(4, HomeController.to.scrollController5),
          _buildList(5, HomeController.to.scrollController6)
        ],
      );
    });
  }

  Widget _buildList(int page, ScrollController scrollController) {
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
      leftPadding: 16.w,
      rightPadding: 16.w,
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
          if (HomeController.to.state.isSelect.value) {
            HomeController.to.selectItem(index, checked);
            return;
          }
          PlayerLogic.to.playMusic(GlobalLogic.to.musicList, index: index);
        },
        onPlayNextTap: (music) => PlayerLogic.to.addNextMusic(music),
        onMoreTap: (music) {
          SmartDialog.compatible.show(
              widget: DialogMoreWithMusic(music: music),
              alignmentTemp: Alignment.bottomCenter);
        },
        onPlayNowTap: () {
          PlayerLogic.to.playMusic(GlobalLogic.to.musicList, index: index);
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
                arguments: GlobalLogic.to.albumList[index]);
          }
        },
      );
    } else if (page == 2) {
      return ListViewItemSinger(
        artist: GlobalLogic.to.artistList[index],
        onItemTap: (artist) {
          Get.toNamed(Routes.routeSingerDetails, arguments: artist);
        },
      );
    } else if (page == 3) {
      return ListViewItemLove(
        index: index,
        music: GlobalLogic.to.loveList[index],
        checked: HomeController.to.isItemChecked(index),
        onPlayNextTap: (music) => PlayerLogic.to.addNextMusic(music),
        onMoreTap: (music) {
          SmartDialog.compatible.show(
              widget: DialogMoreWithMusic(music: music),
              alignmentTemp: Alignment.bottomCenter);
        },
        onPlayNowTap: (index) {
          PlayerLogic.to.playMusic(GlobalLogic.to.loveList, index: index);
        },
      );
    } else if (page == 4) {
      return ListViewItemSongSheet(
        onItemTap: (menu) {
          Get.toNamed(Routes.routeMenuDetails, arguments: menu.id);
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
          if (HomeController.to.state.isSelect.value) {
            HomeController.to.selectItem(index, checked);
            return;
          }
          PlayerLogic.to.playMusic(GlobalLogic.to.musicList, index: index);
        },
        onPlayNextTap: (music) => PlayerLogic.to.addNextMusic(music),
        onMoreTap: (music) {
          SmartDialog.compatible.show(
              widget: DialogMoreWithMusic(music: music),
              alignmentTemp: Alignment.bottomCenter);
        },
        onPlayNowTap: () {
          PlayerLogic.to.playMusic(GlobalLogic.to.recentList, index: index);
        },
      );
    }
  }
}
