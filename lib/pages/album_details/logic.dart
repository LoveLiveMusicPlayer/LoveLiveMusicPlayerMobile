import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Music.dart';

import 'state.dart';

class AlbumDetailsController extends GetxController {
  final AlbumDetailsState state = AlbumDetailsState();

  int getCheckedSong() {
    int num = 0;
    // for (var element in state.items) {
    //   if (element.checked) {
    //     num++;
    //   }
    // }
    return num;
  }

  openSelect() {
    state.isSelect = !state.isSelect;
    refresh();
  }

  isItemChecked(Music index) {
    return false;
    // return state.items[index].checked;
  }

  ///选中单个条目
  selectItem(int index, bool checked) {
    // state.items[index].checked = checked;
    // bool select = true;
    // for (var element in state.items) {
    //   if (!element.checked) {
    //     select = false;
    //   }
    // }
    // state.selectAll = select;
    // refresh();
  }

  ///全选
  selectAll(bool checked) {
    // for (var element in state.items) {
    //   element.checked = checked;
    // }
    // state.selectAll = checked;
    // refresh();
  }
}
