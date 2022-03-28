import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/Music.dart';
import '../../models/music_Item.dart';
import '/network/http_request.dart';

import 'state.dart';

class MainLogic extends GetxController {
  final MainState state = MainState();

  getData() {
    Network.get(
        'https://inventory.scionedev.ilabservice.cloud/api/labbase/v1/company/all?account=17826808739&type=saas',
        success: (w) {
      if (w != null && w is List) {
        for (var element in w) {
          // LogUtil.e(element);
        }
      }
    });
  }

  selectSongLibrary(bool value) {
    state.isSelectSongLibrary = value;
    refresh();
  }

  openSelect() {
    state.isSelect = !state.isSelect;
    refresh();
  }

  addItem(List<MusicItem> data) {
    state.items.addAll(data);
    refresh();
  }

  selectAll(bool checked) {
    for (var element in state.items) {
      element.checked = checked;
    }
    refresh();
  }

  selectItem(int index, bool checked) {
    state.items[index].checked = checked;
    refresh();
  }

  isItemChecked(int index) {
    return state.items[index].checked;
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

  playPrevOrNextMusic(bool isPrev) {
    final tempList = state.playList;
    if (tempList.isEmpty) {
      return;
    }
    int playIndex = checkNowPlaying();
    tempList[playIndex].isPlaying = false;

    Music music;
    if (isPrev) {
      music = playIndex == 0
          ? tempList[tempList.length - 1]
          : tempList[playIndex - 1];
    } else {
      music = playIndex == tempList.length - 1
          ? tempList[0]
          : tempList[playIndex + 1];
    }

    music.isPlaying = true;
    state.playingMusic = music;
    refresh();
    refreshSlidePage();
  }

  refreshSlidePage() async {
    await Future.delayed(const Duration(milliseconds: 200));
    update(["miniPlayer"]);
  }

  togglePlay() {
    state.isPlaying = !state.isPlaying;
    refresh();
  }

  changeMusic(int index) {
    final tempList = state.playList;
    if (tempList.isEmpty) {
      return;
    }
    int playIndex = checkNowPlaying();
    if (index != playIndex) {
      tempList[playIndex].isPlaying = false;
      tempList[index].isPlaying = true;
      state.playingMusic = tempList[index];
      refresh();
    }
  }

  changeTab(int index) {
    final currentIndex = state.currentIndex;
    if (index == 0) {
      if (currentIndex < 3) {
        return;
      }
      state.currentIndex = currentIndex % 3;
    } else {
      if (currentIndex > 2) {
        return;
      }
      state.currentIndex = currentIndex + 3;
    }
    refresh();
  }

  toggleLove() {
    final musicList = state.playList;
    final music = state.playingMusic;
    musicList.forEach((element) {
      if (element.uid == music.uid) {
        element.isLove = !element.isLove;
        state.playingMusic = element;
      }
    });
    refresh();
  }

  int checkNowPlaying() {
    int playIndex = 0;
    for (var element in state.playList) {
      if (element.isPlaying) {
        break;
      } else {
        playIndex++;
      }
    }
    return playIndex;
  }

  ///-------------------------------

  @override
  void onReady() {
    super.onReady();
    state.playingMusic = state.playList[0];
    refresh();
  }
}
