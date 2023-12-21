import 'package:flexible_scrollbar/flexible_scrollbar.dart';
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
import 'package:lovelivemusicplayer/utils/app_utils.dart';
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
  final List<double> scrollOffsets = List<double>.generate(6, (index) => 0.0);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    for (var i = 0; i <= HomeController.scrollControllers.length - 1; i++) {
      final controller = HomeController.scrollControllers[i];
      controller.addListener(() {
        scrollOffsets[i] = controller.offset;
      });
    }

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
        for (var i = 0; i <= HomeController.scrollControllers.length - 1; i++) {
          final controller = HomeController.scrollControllers[i];
          final controllerOffset = scrollOffsets[i];
          checkAndJump(controller, controllerOffset);
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.hidden:
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
          HomeController.to.tabController?.animateTo(index > 2 ? 1 : 0);
          HomeController.to.state.currentIndex.value = index;
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

            ///当前列表是否网格显示
            columnNum: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            leftPadding: hasPadding ? 16.w : 0,
            rightPadding: hasPadding ? 16.w : 0,
            aspectRatio: 0.9,
            listItem: (cxt, index) {
              return _buildListItem(index, page);
            }));
  }

  Widget _buildListItem(int index, int page) {
    /// 0 歌曲  1 专辑  2 歌手  3 我喜欢  4 歌单  5  最近播放
    switch (page) {
      case 0:
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
            });
      case 1:
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
            });
      case 2:
        return ListViewItemSinger(
            artist: GlobalLogic.to.artistList[index],
            onItemTap: (artist) {
              Get.toNamed(Routes.routeSingerDetails, arguments: artist, id: 1);
            });
      case 3:
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
            });
      case 4:
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
            showDevicePic: true);
      default:
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
              PlayerLogic.to
                  .playMusic(GlobalLogic.to.recentList, mIndex: index);
            });
    }
  }
}
