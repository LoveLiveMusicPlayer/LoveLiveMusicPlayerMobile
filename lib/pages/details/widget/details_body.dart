import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/details_list_top.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';

class DetailsBody extends StatefulWidget {
  final DetailController logic;
  final Widget buildCover;
  final List<Music> music;
  final Function(List<String>)? onRemove;
  final bool? isAlbum;
  final int? menuId;

  const DetailsBody({
    super.key,
    required this.logic,
    required this.buildCover,
    required this.music,
    this.isAlbum,
    this.menuId,
    this.onRemove,
  });

  @override
  State<DetailsBody> createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<DetailsBody> {
  var bgColor = Get.theme.primaryColor;
  var hasBgPhotoColor = Get.theme.primaryColor;

  @override
  void initState() {
    final bgPhoto = GlobalLogic.to.bgPhoto.value;
    if (SDUtils.checkFileExist(bgPhoto)) {
      AppUtils.getImagePalette(bgPhoto).then((color) {
        if (color != null) {
          hasBgPhotoColor = color.withAlpha(255);
          setState(() {
            bgColor = Colors.transparent;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: widget.logic.state.isSelect ? () async => false : null,
      child: Expanded(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: widget.buildCover),
            SliverPadding(padding: EdgeInsets.only(top: 10.h)),
            SliverStickyHeader.builder(
              builder: (context, state) {
                if (state.isPinned) {
                  //置顶
                  if (bgColor != hasBgPhotoColor) {
                    bgColor = hasBgPhotoColor;
                  }
                } else {
                  bgColor = Colors.transparent;
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
      bgColor: bgColor,
      selectAll: widget.logic.state.selectAll,
      isSelect: widget.logic.state.isSelect,
      itemsLength: widget.music.length,
      checkedItemLength: widget.logic.getCheckedSong(),
      onPlayTap: () {
        PlayerLogic.to.playMusic(widget.music);
      },
      onScreenTap: () {
        if (widget.logic.state.isSelect) {
          SmartDialog.compatible.dismiss();
        } else {
          widget.logic.openSelect();
          showSelectDialog();
        }
      },
      onSelectAllTap: (checked) {
        widget.logic.selectAll(checked);
      },
      onCancelTap: () {
        SmartDialog.compatible.dismiss();
      },
    );
  }

  Widget renderMusicList() {
    if (widget.menuId != null && DetailController.to.state.isSelect) {
      return SliverReorderableList(
        onReorder: (int oldIndex, int newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }

          setState(() {
            var child = widget.music.removeAt(oldIndex);
            widget.music.insert(newIndex, child);

            DBLogic.to.exchangeMenuItem(
                widget.menuId!, widget.music[oldIndex], widget.music[newIndex]);
          });
        },
        itemBuilder: (context, index) {
          final music = widget.music[index];
          return ReorderableDelayedDragStartListener(
              index: index,
              key: ValueKey("ListViewItemSong${music.musicId}"),
              child: Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: renderItem(index, music, isDraggable: true)));
        },
        itemCount: widget.music.length,
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final music = widget.music[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: renderItem(index, music),
            );
          },
          childCount: widget.music.length,
        ),
      );
    }
  }

  Widget renderItem(int index, Music music, {bool isDraggable = false}) {
    return ListViewItemSong(
      index: index,
      music: music,
      isDraggable: isDraggable,
      checked: widget.logic.isItemChecked(index),
      onItemTap: (index, checked) {
        widget.logic.selectItem(index, checked);
      },
      onPlayNextTap: (music) async {
        await PlayerLogic.to.addNextMusic(music);
      },
      onMoreTap: (music) {
        SmartDialog.compatible.show(
          widget: showDialogMoreWithMusic(music),
          alignmentTemp: Alignment.bottomCenter,
        );
      },
      onPlayNowTap: () {
        PlayerLogic.to.playMusic(widget.music, mIndex: index);
      },
    );
  }

  Widget showDialogMoreWithMusic(Music music) {
    return DialogMoreWithMusic(
      music: music,
      isAlbum: widget.isAlbum,
      onRemove: widget.onRemove != null
          ? (music) => widget.onRemove!([music.musicId!])
          : null,
    );
  }

  showSelectDialog() {
    List<BtnItem> list = [];

    void addToPlaylist() async {
      List<Music> musicList = widget.logic.state.items.cast();
      final tempList = musicList.where((music) => music.checked).toList();
      if (tempList.isEmpty) {
        return;
      }
      final isSuccess = await PlayerLogic.to.addMusicList(tempList);
      if (isSuccess) {
        SmartDialog.compatible.showToast('add_success'.tr);
        SmartDialog.compatible.dismiss();
      }
    }

    void addToMenu() async {
      List<Music> musicList = widget.logic.state.items.cast();
      List<Music> tempList = musicList.where((music) => music.checked).toList();
      if (tempList.isEmpty) {
        return;
      }
      SmartDialog.compatible.show(
        widget: DialogAddSongSheet(
          musicList: tempList,
          changeLoveStatusCallback: (status) {
            widget.logic.changeLoveStatus(tempList, status);
            SmartDialog.compatible.dismiss();
          },
          changeMenuStateCallback: (status) {
            SmartDialog.compatible.dismiss();
          },
        ),
        alignmentTemp: Alignment.bottomCenter,
      );
    }

    void deleteFromMenu() async {
      List<Music> musicList = widget.logic.state.items.cast();
      List<Music> tempList = musicList.where((music) => music.checked).toList();
      if (tempList.isEmpty) {
        return;
      }
      List<String> musicIds = tempList.map((music) => music.musicId!).toList();

      SmartDialog.compatible.show(
        widget: TwoButtonDialog(
          title: "confirm_delete_from_menu".tr,
          isShowMsg: false,
          onConfirmListener: () {
            widget.onRemove!(musicIds);
            SmartDialog.compatible.dismiss();
          },
        ),
      );
    }

    list.add(BtnItem(
      imgPath: Assets.dialogIcAddPlayList2,
      title: 'add_to_playlist'.tr,
      onTap: addToPlaylist,
    ));

    list.add(BtnItem(
      imgPath: Assets.dialogIcAddPlayList,
      title: 'add_to_menu'.tr,
      onTap: addToMenu,
    ));

    if (widget.menuId != null) {
      list.add(BtnItem(
        imgPath: Assets.dialogIcDelete2,
        title: "delete_from_menu".tr,
        onTap: deleteFromMenu,
      ));
    }

    SmartDialog.show(
      builder: (_) => DialogBottomBtn(list: list),
      usePenetrate: true,
      clickMaskDismiss: false,
      maskColor: Colors.transparent,
      alignment: Alignment.bottomCenter,
      onDismiss: () => widget.logic.closeSelect(),
    );
  }
}
