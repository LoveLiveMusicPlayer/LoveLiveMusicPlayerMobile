import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/home/home_state.dart';

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
