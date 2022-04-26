import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/home/home_state.dart';

class HomeController extends GetxController {
  final HomeState state = HomeState();

  static HomeController get to => Get.find();

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

  ///全选
  selectAll(bool checked) {
    // for (var element in state.items) {
    //   element.checked = checked;
    // }
    // refresh();
  }

  ///选中单个条目
  selectItem(Object obj, bool checked) {

    // state.items[index].checked = checked;
    // bool select = true;
    // for (var element in state.items) {
    //   if (!element.checked) {
    //     select = false;
    //   }
    // }
    // state.selectAll = select;
    //
    // refresh();
  }

  isItemChecked(int index) {
    return false;
    // return state.items[index].checked;
  }

  int getCheckedSong() {
    int num = 47;
    // for (var element in state.items) {
    //   if (element.checked) {
    //     num++;
    //   }
    // }
    return num;
  }

  playPrevOrNextMusic(bool isPrev) {
    final tempList = PlayerLogic.to.mPlayList;
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
    PlayerLogic.to.playingMusic.value = music;
    refresh();
    refreshSlidePage();
    getLrc();
  }

  refreshSlidePage() async {
    await Future.delayed(const Duration(milliseconds: 200));
    update(["miniPlayer"]);
  }

  changeMusic(int index) {
    final tempList = PlayerLogic.to.mPlayList;
    if (tempList.isEmpty) {
      return;
    }
    int playIndex = checkNowPlaying();
    if (index != playIndex) {
      tempList[playIndex].isPlaying = false;
      tempList[index].isPlaying = true;
      PlayerLogic.to.playingMusic.value = tempList[index];
      refresh();
      refreshSlidePage();
      getLrc();
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
    resetCheckedState();
    refresh();
  }

  ///重置选中状态
  resetCheckedState() {
    // state.isSelect = false;
    // state.selectAll = false;
    // for (var element in state.items) {
    //   element.checked = false;
    // }
  }

  toggleLove() {

    refresh();
  }

  toggleTranslate() {
    switch (PlayerLogic.to.lrcType.value) {
      case 0:
        PlayerLogic.to.lrcType.value = 1;
        break;
      case 1:
        PlayerLogic.to.lrcType.value = 2;
        break;
      case 2:
        PlayerLogic.to.lrcType.value = 0;
        break;
    }
    refresh();
  }

  int checkNowPlaying() {
    int playIndex = 0;
    for (var element in PlayerLogic.to.mPlayList) {
      if (element.isPlaying) {
        break;
      } else {
        playIndex++;
      }
    }
    return playIndex;
  }

  getLrc() async {
    final jp = PlayerLogic.to.playingMusic.value.jpUrl;
    final zh = PlayerLogic.to.playingMusic.value.zhUrl;
    final roma = PlayerLogic.to.playingMusic.value.romaUrl;
    if (jp == null || jp.isEmpty) {
      PlayerLogic.to.jpLrc.value = "";
    } else {
      PlayerLogic.to.jpLrc.value = await Network.getSync(jp);
    }
    if (zh == null || zh.isEmpty) {
      PlayerLogic.to.zhLrc.value = "";
    } else {
      PlayerLogic.to.zhLrc.value = await Network.getSync(zh);
    }
    if (roma == null || roma.isEmpty) {
      PlayerLogic.to.romaLrc.value = "";
    } else {
      PlayerLogic.to.romaLrc.value = await Network.getSync(roma);
    }
    refresh();
  }

  ///-------------------------------

  @override
  void onReady() {
    super.onReady();
    if (PlayerLogic.to.mPlayList.isNotEmpty) {
      PlayerLogic.to.playingMusic.value = PlayerLogic.to.mPlayList[0];
    }
    refresh();
    getLrc();
  }

///-------------------------

}