import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/details/state.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';

class DetailController extends GetxController {
  final AlbumDetailState state = AlbumDetailState();

  static DetailController get to => Get.find();

  openSelect() {
    state.isSelect = true;
    HomeController.to.state.selectMode.value = 1;
    refresh();
  }

  closeSelect() {
    final tempList = state.items;
    if (tempList.isNotEmpty) {
      for (var element in tempList) {
        element.checked = false;
      }
    }
    state.selectAll = false;
    HomeController.to.state.selectMode.value = 0;
    state.isSelect = false;
    refresh();
  }

  ///全选
  selectAll(bool checked) {
    final tempList = state.items;
    if (tempList.isNotEmpty) {
      for (var element in tempList) {
        element.checked = checked;
      }
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
    final tempList = state.items;
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

  changeLoveStatus(List<Music> changeList, bool status) {
    for (var music in state.items) {
      for (var cMusic in changeList) {
        if (music.musicId == cMusic.musicId) {
          music.isLove = status;
        }
      }
    }
    refresh();
  }
}
