import 'package:flexible_scrollbar/flexible_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/page_view/keep_alive_wrapper.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_album.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_singer.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_song_sheet.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/dynamic_height_gridview.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';
import 'package:lovelivemusicplayer/widgets/refresher_widget.dart';

class PageViewComponent extends GetView<PageViewLogic> {
  const PageViewComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PageView(
          controller: controller.pageController,
          physics: HomeController.to.state.selectMode.value > 0
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          onPageChanged: controller.onPageChanged,
          children: HomeController.scrollControllers
              .asMap()
              .entries
              .map((entry) => KeepAliveWrapper(child: _buildList(entry.key)))
              .toList());
    });
  }

  Widget _buildList(int page) {
    final scrollController = HomeController.scrollControllers[page];
    final itemCount =
        GlobalLogic.to.getListSize(page, GlobalLogic.to.databaseInitOver.value);

    /// 处理空白页
    if (itemCount <= 0) {
      return Padding(
        padding: EdgeInsets.only(top: (page == 2 || page == 4) ? 35.h : 0),
        child: _buildNullWidget(),
      );
    }

    /// 渲染专辑页
    if (page == 1) {
      return Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 75.h),
        child: DynamicHeightGridView(
          controller: scrollController,
          builder: (BuildContext context, int index) =>
              _buildListItem(index, page),
          itemCount: itemCount,
          crossAxisCount: AppUtils.calcAlbumColumn(),
          mainAxisSpacing: 0,
          crossAxisSpacing: 10.w,
        ),
      );
    }

    /// 渲染其他页
    final currentPage = HomeController.to.state.currentIndex.value;
    final hasPadding = currentPage == 2 || currentPage == 4;
    final canReorder =
        page == 3 && HomeController.to.state.selectMode.value == 1;
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
            itemCount: itemCount,
            enablePullUp: false,
            enablePullDown: false,
            canReorder: canReorder,

            ///当前列表是否网格显示
            mainAxisSpacing: 0,
            crossAxisSpacing: 10.w,
            leftPadding: hasPadding ? 16.w : 0,
            rightPadding: hasPadding ? 16.w : 0,
            listItem: (cxt, index) => _buildListItem(index, page)));
  }

  /// 空白页
  Widget _buildNullWidget() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Assets.mainIcNull, width: 80.h, height: 80.h),
          SizedBox(height: 10.h),
          Text('no_data'.tr, style: TextStyleMs.colorBFBFBF_18)
        ],
      ),
    );
  }

  Widget _buildListItem(int index, int page) {
    /// 0 歌曲  1 专辑  2 歌手  3 我喜欢  4 歌单  5  最近播放
    Widget widget;
    Key key;
    switch (page) {
      case 0:
        final music = GlobalLogic.to.musicList[index];
        key = ValueKey("ListViewItemSong${music.musicId}");
        widget = ListViewItemSong(
            index: index,
            musicList: GlobalLogic.to.musicList,
            onItemTap: HomeController.to.selectItem,
            onMoreTap: controller.showMoreDialog,
            checked: HomeController.to.isItemChecked(index));
        break;
      case 1:
        final album = GlobalLogic.to.albumList[index];
        key = ValueKey("ListViewItemAlbum${album.albumId}");
        widget =
            ListViewItemAlbum(album: album, onItemTap: controller.onItemTap);
        break;
      case 2:
        final artist = GlobalLogic.to.artistList[index];
        key = ValueKey("ListViewItemSinger${artist.id}");
        widget =
            ListViewItemSinger(artist: artist, onItemTap: controller.onItemTap);
        break;
      case 3:
        final music = GlobalLogic.to.loveList[index];
        key = ValueKey("ListViewItemLove${music.musicId}");
        widget = ListViewItemSong(
            index: index,
            musicList: GlobalLogic.to.loveList,
            onItemTap: HomeController.to.selectItem,
            onMoreTap: controller.showMoreDialog,
            isDraggable: true,
            checked: HomeController.to.isItemChecked(index));
        break;
      case 4:
        final menu = GlobalLogic.to.menuList[index];
        key = ValueKey("ListViewItemSheet${menu.id}");
        widget = ListViewItemSongSheet(
            onItemTap: controller.onItemTap,
            onMoreTap: controller.showMoreDialog,
            menu: menu,
            showDevicePic: true);
        break;
      default:
        final music = GlobalLogic.to.recentList[index];
        key = ValueKey("ListViewItemRecent${music.musicId}");
        widget = ListViewItemSong(
            index: index,
            musicList: GlobalLogic.to.recentList,
            onItemTap: HomeController.to.selectItem,
            onMoreTap: controller.showMoreDialog,
            checked: HomeController.to.isItemChecked(index));
        break;
    }
    return Padding(
        key: key, padding: EdgeInsets.symmetric(vertical: 5.h), child: widget);
  }
}
