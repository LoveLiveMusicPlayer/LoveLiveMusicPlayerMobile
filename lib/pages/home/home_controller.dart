import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/pages/home/home_state.dart';

class HomeController extends GetxController {
  final HomeState state = HomeState();

  TabController? tabController;

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();
  ScrollController scrollController3 = ScrollController();
  ScrollController scrollController4 = ScrollController();
  ScrollController scrollController5 = ScrollController();
  ScrollController scrollController6 = ScrollController();

  static HomeController get to => Get.find();

  selectSongLibrary(bool value) {
    state.isSelectSongLibrary = value;
    refresh();
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
        state.items = [...GlobalLogic.to.recentlyList];
        break;
      default:
        break;
    }
    state.isSelect.value = true;
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
    state.isSelect.value = false;
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
