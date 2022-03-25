import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/music_Item.dart';

import 'state.dart';

class Song_libraryLogic extends GetxController {
  final Song_libraryState state = Song_libraryState();

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
}
