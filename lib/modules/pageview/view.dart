import 'package:flexible_scrollbar/flexible_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/page_view/keep_alive_wrapper.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_menu.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_album.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_singer.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_song_sheet.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';
import 'package:lovelivemusicplayer/widgets/refresher_widget.dart';

class PageViewComponent extends StatefulWidget {
  const PageViewComponent({super.key});

  @override
  State<PageViewComponent> createState() => _PageViewComponentState();
}

class _PageViewComponentState extends State<PageViewComponent> {
  @override
  void initState() {
    super.initState();
    for (var i = 0; i <= HomeController.scrollControllers.length - 1; i++) {
      final controller = HomeController.scrollControllers[i];
      controller.addListener(() {
        HomeController.scrollOffsets[i] = controller.offset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(PageViewLogic());

    return Obx(() {
      final children = <KeepAliveWrapper>[];
      for (var i = 0; i <= HomeController.scrollControllers.length - 1; i++) {
        children.add(KeepAliveWrapper(
            child: _buildList(i, HomeController.scrollControllers[i])));
      }
      return PageView(
        controller: logic.controller,
        physics: HomeController.to.state.isSelect.value
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        onPageChanged: (index) {
          HomeController.to.state.currentIndex.value = index;
          HomeController.to.tabController?.animateTo(index > 2 ? 1 : 0);
        },
        children: children,
      );
    });
  }

  Widget _buildList(int page, ScrollController scrollController) {
    final currentPage = HomeController.to.state.currentIndex.value;
    final hasPadding = currentPage == 1 || currentPage == 2 || currentPage == 4;
    return FlexibleScrollbar(
        controller: scrollController,
        touchBar: () => AppUtils.vibrate(),
        scrollThumbBuilder: (ScrollbarInfo info) {
          return AnimatedContainer(
            width: info.isDragging ? 12.w : 10.w,
            height: info.thumbMainAxisSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: Colors.grey.withOpacity(0.6),
            ),
            duration: const Duration(seconds: 1),
          );
        },
        child: RefresherWidget(
            scrollController: scrollController,
            itemCount: GlobalLogic.to
                .getListSize(page, GlobalLogic.to.databaseInitOver.value),
            enablePullUp: false,
            enablePullDown: false,
            isGridView: page == 1,
            canReorder: page == 3 && HomeController.to.state.isSelect.value,

            ///当前列表是否网格显示
            columnNum: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            leftPadding: hasPadding ? 16.w : 0,
            rightPadding: hasPadding ? 16.w : 0,
            listItem: (cxt, index) {
              return _buildListItem(index, page);
            }));
  }

  Widget _buildListItem(int index, int page) {
    /// 0 歌曲  1 专辑  2 歌手  3 我喜欢  4 歌单  5  最近播放
    Widget widget;
    Key key;
    switch (page) {
      case 0:
        key = ValueKey(
            "ListViewItemSong${GlobalLogic.to.musicList[index].musicId}");
        widget = ListViewItemSong(
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
            });
        break;
      case 1:
        key = ValueKey(
            "ListViewItemAlbum${GlobalLogic.to.albumList[index].albumId}");
        widget = ListViewItemAlbum(
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
            });
        break;
      case 2:
        key = ValueKey(
            "ListViewItemSinger${GlobalLogic.to.artistList[index].id}");
        widget = ListViewItemSinger(
            artist: GlobalLogic.to.artistList[index],
            onItemTap: (artist) {
              Get.toNamed(Routes.routeSingerDetails, arguments: artist, id: 1);
            });
        break;
      case 3:
        key = ValueKey(
            "ListViewItemLove${GlobalLogic.to.loveList[index].musicId}");
        widget = ListViewItemSong(
            index: index,
            music: GlobalLogic.to.loveList[index],
            isDraggable: true,
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
            });
        break;
      case 4:
        key = ValueKey("ListViewItemSheet${GlobalLogic.to.menuList[index].id}");
        widget = ListViewItemSongSheet(
            onItemTap: (menu) {
              Get.toNamed(Routes.routeMenuDetails, arguments: menu.id, id: 1);
            },
            onMoreTap: (menu) {
              SmartDialog.compatible.show(
                  widget: DialogMoreWithMenu(menu: menu),
                  alignmentTemp: Alignment.bottomCenter);
            },
            menu: GlobalLogic.to.menuList[index],
            showDevicePic: true);
        break;
      default:
        key = ValueKey(
            "ListViewItemRecent${GlobalLogic.to.recentList[index].musicId}");
        widget = ListViewItemSong(
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
              PlayerLogic.to
                  .playMusic(GlobalLogic.to.recentList, mIndex: index);
            });
        break;
    }
    return Padding(
        key: key, padding: EdgeInsets.symmetric(vertical: 5.h), child: widget);
  }
}
