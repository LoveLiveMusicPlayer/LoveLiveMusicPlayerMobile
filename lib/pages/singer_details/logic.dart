import 'package:get/get.dart';

import 'state.dart';

class SingerDetailsLogic extends GetxController {
  final SingerDetailsState state = SingerDetailsState();

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

  isItemChecked(Object index) {
    return false;
    // return state.items[index].checked;
  }

  ///选中单个条目
  selectItem(Object index, bool checked) {
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

  ///全选
  selectAll(bool checked) {
    // for (var element in state.items) {
    //   element.checked = checked;
    // }
    // state.selectAll = checked;
    // refresh();
  }
}
