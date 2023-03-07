import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/details_list_top.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';
import 'package:sticky_headers/sticky_headers.dart';

class DetailsBody extends StatefulWidget {
  final DetailController logic;
  final Widget buildCover;
  final List<Music> music;
  final Function(Music)? onRemove;
  final bool? isAlbum;

  const DetailsBody(
      {Key? key,
      required this.logic,
      required this.buildCover,
      required this.music,
      this.isAlbum,
      this.onRemove})
      : super(key: key);

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
          bgColor = color.withAlpha(255);
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: widget.logic.state.isSelect
            ? () async {
                return false;
              }
            : null,
        child: Expanded(
            child: ListView(
          padding: const EdgeInsets.all(0),
          children: getListItems(widget.logic),
        )));
  }

  List<Widget> getListItems(logic) {
    List<Widget> list = [];
    list.add(widget.buildCover);
    list.add(SizedBox(
      height: 10.h,
    ));
    list.add(StickyHeaderBuilder(
        builder: (BuildContext context, double stuckAmount) {
          var hasBg = stuckAmount < 0;
          return DetailsListTop(
              hasBg: hasBg,
              bgColor: bgColor,
              selectAll: logic.state.selectAll,
              isSelect: logic.state.isSelect,
              itemsLength: widget.music.length,
              checkedItemLength: logic.getCheckedSong(),
              onPlayTap: () {
                PlayerLogic.to.playMusic(widget.music);
              },
              onScreenTap: () {
                if (logic.state.isSelect) {
                  SmartDialog.compatible.dismiss();
                } else {
                  logic.openSelect();
                  showSelectDialog();
                }
              },
              onSelectAllTap: (checked) {
                logic.selectAll(checked);
              },
              onCancelTap: () {
                SmartDialog.compatible.dismiss();
              });
        },
        content: Column(
          children: renderMusicList(logic),
        )));
    return list;
  }

  List<Widget> renderMusicList(logic) {
    List<Widget> list = [];
    list.add(SizedBox(
      height: 10.h,
    ));
    for (var index = 0; index < widget.music.length; index++) {
      list.add(Padding(
        padding: EdgeInsets.only(left: 16.w, bottom: 20.h, right: 16.w),
        child: ListViewItemSong(
          index: index,
          music: widget.music[index],
          checked: logic.isItemChecked(index),
          onItemTap: (index, checked) {
            logic.selectItem(index, checked);
          },
          onPlayNextTap: (music) {
            PlayerLogic.to.addNextMusic(music);
            SmartDialog.compatible.showToast('add_success'.tr);
          },
          onMoreTap: (music) {
            SmartDialog.compatible.show(
                widget: showDialogMoreWithMusic(music),
                alignmentTemp: Alignment.bottomCenter);
          },
          onPlayNowTap: () {
            PlayerLogic.to.playMusic(widget.music, index: index);
          },
        ),
      ));
    }
    if (logic.state.isSelect) {
      list.add(SizedBox(
        height: 102.h,
      ));
    }
    return list;
  }

  Widget showDialogMoreWithMusic(Music music) {
    if (widget.onRemove == null) {
      return DialogMoreWithMusic(music: music, isAlbum: widget.isAlbum);
    }
    return DialogMoreWithMusic(
        music: music,
        isAlbum: widget.isAlbum,
        onRemove: (music) {
          widget.onRemove!(music);
        });
  }

  showSelectDialog() {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList2,
        title: 'add_to_playlist'.tr,
        onTap: () async {
          final musicList = widget.logic.state.items;
          final tempList = <Music>[];
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              tempList.add(music);
            }
          });
          final isSuccess = PlayerLogic.to.addMusicList(tempList);
          if (isSuccess) {
            SmartDialog.compatible.showToast('add_success'.tr);
          }
          SmartDialog.compatible.dismiss();
        }));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList,
        title: 'add_to_menu'.tr,
        onTap: () async {
          List<Music> musicList = widget.logic.state.items.cast();
          var isHasChosen = widget.logic.state.items
              .any((element) => element.checked == true);
          if (!isHasChosen) {
            SmartDialog.compatible.dismiss();
            return;
          }
          List<Music> tempList = [];
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              tempList.add(music);
            }
          });
          SmartDialog.compatible.dismiss();
          SmartDialog.compatible.show(
              widget: DialogAddSongSheet(
                  musicList: tempList,
                  changeLoveStatusCallback: (status) {
                    widget.logic.changeLoveStatus(tempList, status);
                  }),
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
        onDismiss: () => widget.logic.closeSelect());
  }
}
