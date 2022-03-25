import 'package:get/get.dart';

import 'state.dart';

class Song_libraryLogic extends GetxController {
  final Song_libraryState state = Song_libraryState();

  openSelect(){
    state.isSelect = !state.isSelect;
    refresh();
  }
  addItem(List<String> data){
    state.items.addAll(data);
    refresh();
  }

}
