import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/logic.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';

class DetailsBodyLogic extends GetxController {
  var bgColor = Get.theme.primaryColor;
  var hasBgPhotoColor = Get.theme.primaryColor;
  late DetailController logic;

  @override
  void onReady() {
    super.onReady();
    final bgPhoto = GlobalLogic.to.bgPhoto.value;
    if (SDUtils.checkFileExist(bgPhoto)) {
      AppUtils.getImagePalette(bgPhoto).then((color) {
        if (color != null) {
          hasBgPhotoColor = color.withAlpha(255);
          bgColor = Colors.transparent;
          refresh();
        }
      });
    }
  }

  playAll() {
    PlayerLogic.to.playMusic(logic.state.items);
  }

  onFunctionTap(bool isAlbum, Function(List<String>)? onRemove) {
    if (logic.state.isSelect) {
      SmartDialog.dismiss();
    } else {
      logic.openSelect();
      showSelectDialog(isAlbum, onRemove);
    }
  }

  onReorder(int oldIndex, int newIndex, int menuId) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var child = logic.state.items.removeAt(oldIndex);
    logic.state.items.insert(newIndex, child);
    await DBLogic.to.exchangeMenuItem(menuId, oldIndex, newIndex);
    final menu = await DBLogic.to.menuDao.findMenuById(menuId);
    if (menu != null) {
      (logic as MenuDetailController).menu = menu;
      logic.refreshData();
    }
  }

  onMoreTap(Music music, bool? isAlbum, Function(List<String>)? onRemove) {
    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        builder: (context) {
          return DialogMoreWithMusic(
            music: music,
            isAlbum: isAlbum,
            onRemove:
                onRemove != null ? (music) => onRemove([music.musicId!]) : null,
          );
        });
  }

  showSelectDialog(bool isAlbum, Function(List<String>)? onRemove) {
    List<BtnItem> list = [];

    void addToPlaylist() async {
      List<Music> musicList = logic.state.items.cast();
      final tempList = musicList.where((music) => music.checked).toList();
      if (tempList.isEmpty) {
        return;
      }
      final isSuccess = await PlayerLogic.to.addMusicList(tempList);
      if (isSuccess) {
        SmartDialog.showToast('add_success'.tr);
        SmartDialog.dismiss();
      }
    }

    void addToMenu() {
      List<Music> musicList = logic.state.items.cast();
      List<Music> tempList = musicList.where((music) => music.checked).toList();
      if (tempList.isEmpty) {
        return;
      }
      SmartDialog.show(
          alignment: Alignment.bottomCenter,
          builder: (context) {
            return DialogAddSongSheet(
              musicList: tempList,
              changeLoveStatusCallback: (status) {
                logic.changeLoveStatus(tempList, status);
                SmartDialog.dismiss();
              },
              changeMenuStateCallback: (status) {
                SmartDialog.dismiss();
              },
            );
          });
    }

    void deleteFromMenu() {
      List<Music> musicList = logic.state.items.cast();
      List<Music> tempList = musicList.where((music) => music.checked).toList();
      if (tempList.isEmpty) {
        return;
      }
      List<String> musicIds = tempList.map((music) => music.musicId!).toList();

      SmartDialog.show(builder: (context) {
        return TwoButtonDialog(
          title: "confirm_delete_from_menu".tr,
          isShowMsg: false,
          onConfirmListener: () {
            onRemove!(musicIds);
            SmartDialog.dismiss();
          },
        );
      });
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

    if (isAlbum == true) {
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
      onDismiss: () => logic.closeSelect(),
    );
  }
}
