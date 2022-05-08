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

  changeTab(int index) {
    final currentIndex = state.currentIndex.value;
    if (index == 0) {
      if (currentIndex < 3) {
        return;
      }
      state.currentIndex.value = currentIndex % 3;
    } else {
      if (currentIndex > 2) {
        return;
      }
      state.currentIndex.value = currentIndex + 3;
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

  ///-------------------------------

  @override
  void onReady() {
    super.onReady();
    if (PlayerLogic.to.mPlayList.isNotEmpty) {
      PlayerLogic.to.playingMusic.value = PlayerLogic.to.mPlayList[0];
    }
    refresh();
  }

///-------------------------

}