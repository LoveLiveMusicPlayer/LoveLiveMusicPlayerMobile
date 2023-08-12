import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
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
  final bool? isMenu;

  const DetailsBody({
    Key? key,
    required this.logic,
    required this.buildCover,
    required this.music,
    this.isAlbum,
    this.isMenu,
    this.onRemove,
  }) : super(key: key);

  @override
  State<DetailsBody> createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<DetailsBody> {
  var bgColor = Get.theme.primaryColor;

  @override
  void initState() {
    final bgPhoto = GlobalLogic.to.bgPhoto.value;
    if (SDUtils.checkFileExist(bgPhoto)) {
      AppUtils.getImagePalette(bgPhoto).then((color) {
        if (color != null) {
          setState(() {
            bgColor = color.withAlpha(255);
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
            SliverStickyHeader(
              header: renderStickyHeader(),
              sliver: renderMusicList(),
            ),
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final music = widget.music[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: ListViewItemSong(
              index: index,
              music: music,
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
            ),
          );
        },
        childCount: widget.music.length,
      ),
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
      final musicList = widget.logic.state.items;
      final tempList = musicList.where((music) => music.checked).toList();
      final isSuccess = await PlayerLogic.to.addMusicList(tempList);
      if (isSuccess) {
        SmartDialog.compatible.showToast('add_success'.tr);
      }
      SmartDialog.compatible.dismiss();
    }

    void addToMenu() async {
      List<Music> musicList = widget.logic.state.items.cast();
      var isHasChosen = musicList.any((element) => element.checked == true);
      if (!isHasChosen) {
        SmartDialog.compatible.dismiss();
        return;
      }
      List<Music> tempList = musicList.where((music) => music.checked).toList();
      SmartDialog.compatible.dismiss();
      SmartDialog.compatible.show(
        widget: DialogAddSongSheet(
          musicList: tempList,
          changeLoveStatusCallback: (status) {
            widget.logic.changeLoveStatus(tempList, status);
          },
        ),
        alignmentTemp: Alignment.bottomCenter,
      );
    }

    void deleteFromMenu() async {
      List<Music> musicList = widget.logic.state.items.cast();
      var isHasChosen = musicList.any((element) => element.checked == true);
      if (!isHasChosen) {
        SmartDialog.compatible.dismiss();
        return;
      }
      List<String> musicIds = musicList
          .where((music) => music.checked)
          .map((music) => music.musicId!)
          .toList();

      SmartDialog.compatible.show(
        widget: TwoButtonDialog(
          title: "confirm_delete_from_menu".tr,
          isShowMsg: false,
          onConfirmListener: () => widget.onRemove!(musicIds),
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

    if (widget.isMenu == true) {
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
