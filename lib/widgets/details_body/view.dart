import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/details/album_details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/logic.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/widgets/details_body/logic.dart';
import 'package:lovelivemusicplayer/widgets/details_list_top.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';

class DetailsBody extends GetView<DetailsBodyLogic> {
  final DetailController logic;
  final Widget buildCover;
  final Function(List<String>)? onRemove;

  const DetailsBody(
      {super.key,
      required this.logic,
      required this.buildCover,
      this.onRemove});

  @override
  Widget build(BuildContext context) {
    controller.logic = logic;
    return WillPopScope(
      onWillPop: logic.state.isSelect ? () async => false : null,
      child: Expanded(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Container(
              padding: EdgeInsets.only(top: 16.h, bottom: 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [buildCover],
              ),
            )),
            SliverStickyHeader.builder(
              builder: (context, state) {
                if (state.isPinned) {
                  //置顶
                  if (controller.bgColor != controller.hasBgPhotoColor) {
                    controller.bgColor = controller.hasBgPhotoColor;
                  }
                } else {
                  controller.bgColor = Colors.transparent;
                }

                return renderStickyHeader();
              },
              sliver: renderMusicList(),
            )
          ],
        ),
      ),
    );
  }

  Widget renderStickyHeader() {
    return DetailsListTop(
      hasBg: true,
      bgColor: controller.bgColor,
      selectAll: logic.state.selectAll,
      isSelect: logic.state.isSelect,
      itemsLength: logic.state.items.length,
      checkedItemLength: logic.getCheckedSong(),
      onPlayTap: controller.playAll,
      onFunctionTap: () =>
          controller.onFunctionTap(logic is AlbumDetailController, onRemove),
      onSelectAllTap: logic.selectAll,
      onCancelTap: SmartDialog.dismiss,
    );
  }

  Widget renderMusicList() {
    final musicList = logic.state.items;
    if (logic is MenuDetailController && logic.state.isSelect) {
      return SliverReorderableList(
        onReorderStart: (int index) => AppUtils.vibrate(),
        onReorder: (int oldIndex, int newIndex) {
          final menu = (logic as MenuDetailController).menu;
          controller.onReorder(oldIndex, newIndex, menu.id);
        },
        itemBuilder: (context, index) {
          final music = musicList[index];
          return ReorderableDelayedDragStartListener(
              index: index,
              key: ValueKey("ListViewItemSong${music.musicId}"),
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: musicList.length - 1 == index ? 95.h : 10.h),
                  child: renderItem(index, music, isDraggable: true)));
        },
        itemCount: musicList.length,
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final music = musicList[index];
            return Padding(
              padding: EdgeInsets.only(
                  bottom: musicList.length - 1 == index ? 95.h : 10.h),
              child: renderItem(index, music),
            );
          },
          childCount: musicList.length,
        ),
      );
    }
  }

  Widget renderItem(int index, Music music, {bool isDraggable = false}) {
    return ListViewItemSong(
        index: index,
        musicList: logic.state.items,
        isDraggable: isDraggable,
        checked: logic.isItemChecked(index),
        onItemTap: logic.selectItem,
        onMoreTap: (music) => controller.onMoreTap(
            music, logic is AlbumDetailController, onRemove));
  }
}
