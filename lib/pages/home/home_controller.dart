import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/home/home_state.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';

class HomeController extends GetxController {
  final HomeState state = HomeState();

  TabController? tabController;

  static final List<ScrollController> scrollControllers =
      List<ScrollController>.generate(6, (index) => ScrollController());

  static final List<double> scrollOffsets =
      List<double>.generate(6, (index) => 0.0);

  static HomeController get to => Get.find();

  static checkAndJump(ScrollController controller, double offset) {
    if (controller.hasClients) {
      controller.jumpTo(offset);
    }
  }

  openSelect() {
    switch (state.currentIndex.value) {
      case 0:
        state.items = [...GlobalLogic.to.musicList];
        break;
      case 1:
        state.items = [...GlobalLogic.to.albumList];
        break;
      case 2:
        state.items = [...GlobalLogic.to.artistList];
        break;
      case 3:
        state.items = [...GlobalLogic.to.loveList];
        break;
      case 4:
        state.items = [...GlobalLogic.to.menuList];
        break;
      case 5:
        state.items = [...GlobalLogic.to.recentList];
        break;
      default:
        break;
    }
    state.selectMode.value = 1;
    showSelectDialog();
  }

  showSelectDialog() {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList2,
        title: 'add_to_playlist'.tr,
        onTap: () async {
          List<Music> musicList = state.items.cast();
          var isHasChosen =
              state.items.any((element) => element.checked == true);
          if (!isHasChosen) {
            return;
          }
          List<Music> tempList = [];
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              tempList.add(music);
            }
          });
          final isSuccess = await PlayerLogic.to.addMusicList(tempList);
          if (isSuccess) {
            SmartDialog.showToast('add_success'.tr);
          }
          SmartDialog.dismiss();
        }));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList,
        title: 'add_to_menu'.tr,
        onTap: () async {
          List<Music> musicList = state.items.cast();
          var isHasChosen =
              state.items.any((element) => element.checked == true);
          if (!isHasChosen) {
            return;
          }
          List<Music> tempList = [];
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              tempList.add(music);
            }
          });
          SmartDialog.show(
              alignment: Alignment.bottomCenter,
              builder: (context) {
                return DialogAddSongSheet(
                    musicList: tempList,
                    changeLoveStatusCallback: (status) {
                      SmartDialog.dismiss();
                    },
                    changeMenuStateCallback: (status) {
                      SmartDialog.dismiss();
                    });
              });
        }));
    if (HomeController.to.state.currentIndex.value == 3) {
      // 仅在我喜欢中添加此按钮
      list.add(BtnItem(
          imgPath: Assets.dialogIcDelete2,
          title: "cancel_i_like".tr,
          onTap: () async {
            List<Music> musicList = state.items.cast();
            var isHasChosen =
                state.items.any((element) => element.checked == true);
            if (!isHasChosen) {
              return;
            }
            List<Music> tempList = [];
            await Future.forEach<Music>(musicList, (music) {
              if (music.checked) {
                tempList.add(music);
              }
            });
            SmartDialog.show(builder: (context) {
              return TwoButtonDialog(
                  title: "confirm_to_delete_music".tr,
                  isShowMsg: false,
                  onConfirmListener: () {
                    bool notAllLove =
                        tempList.any((music) => music.isLove == false);
                    PlayerLogic.to.toggleLoveList(tempList, notAllLove);
                    SmartDialog.dismiss();
                  });
            });
          }));
    }
    SmartDialog.show(
        usePenetrate: true,
        clickMaskDismiss: false,
        maskColor: Colors.transparent,
        alignment: Alignment.bottomCenter,
        onDismiss: closeSelect,
        builder: (context) => DialogBottomBtn(list: list));
  }

  filterItem(String str) {
    final musicList = <Music>[];

    handleData(List<Music> refList) {
      for (int i = 0; i < refList.length; i++) {
        final music = refList[i];
        if (music.musicName?.toLowerCase().contains(str.toLowerCase()) ==
            true) {
          musicList.add(music);
        }
      }
    }

    switch (state.currentIndex.value) {
      case 0:
        handleData(state.oldMusicList);
        GlobalLogic.to.musicList.value = musicList;
        break;
      case 3:
        handleData(state.oldLoveList);
        GlobalLogic.to.loveList.value = musicList;
        break;
      case 5:
        handleData(state.oldRecentList);
        GlobalLogic.to.recentList.value = musicList;
        break;
      default:
        break;
    }
  }

  closeFilter() {
    filterItem("");
    state.searchControl.clear();
    state.oldMusicList.clear();
    state.oldLoveList.clear();
    state.oldRecentList.clear();
  }

  sortItem() {
    final saveValue = GlobalLogic.to.sortMode.value == "ASC" ? "DESC" : "ASC";
    GlobalLogic.to.sortMode.value = saveValue;
    SpUtil.put(Const.spSortOrder, saveValue);
    switch (state.currentIndex.value) {
      case 0:
        GlobalLogic.to.musicList.value =
            GlobalLogic.to.musicList.reversed.toList();
        break;
      case 3:
        GlobalLogic.to.loveList.value =
            GlobalLogic.to.loveList.reversed.toList();
        break;
      case 5:
        GlobalLogic.to.recentList.value =
            GlobalLogic.to.recentList.reversed.toList();
        break;
      default:
        break;
    }
  }

  onPlayTap() {
    PlayerLogic.to.playMusic(
        GlobalLogic.to.filterMusicListByIndex(state.currentIndex.value));
  }

  closeSelect() {
    final tempList = state.items;
    if (tempList.isNotEmpty) {
      for (var element in tempList) {
        element.checked = false;
      }
    }
    state.selectAll = false;
    refresh();
    state.selectMode.value = 0;
  }

  ///全选
  selectAll(bool checked) {
    final tempList = state.items;
    if (tempList.isNotEmpty) {
      for (var element in tempList) {
        element.checked = checked;
      }
      GlobalLogic.to.setList(state.currentIndex.value, tempList);
    }
    state.selectAll = checked;
    refresh();
  }

  ///选中单个条目
  selectItem(int index, bool checked) {
    state.items[index].checked = checked;
    bool select = true;
    for (var element in state.items) {
      if (!element.checked) {
        select = false;
      }
    }
    state.selectAll = select;
    refresh();
  }

  isItemChecked(int index) {
    final tempList = state.items.cast();
    if (index >= 0 && index < tempList.length) {
      return tempList[index].checked;
    }
    return false;
  }

  int getCheckedSong() {
    int num = 0;
    for (var element in state.items) {
      if (element.checked) {
        num++;
      }
    }
    return num;
  }
}
