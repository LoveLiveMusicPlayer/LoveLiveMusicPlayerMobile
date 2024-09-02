import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

class MenuDetailController extends DetailController {
  Menu menu = NestedController.to.menu;

  @override
  void onInit() {
    state.title = menu.name;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
    AppUtils.uploadEvent("MenuDetailsPage");
  }

  @override
  refreshData() {
    final tempList = menu.music;
    if (tempList.isEmpty) {
      refresh();
    } else {
      DBLogic.to.findMusicByMusicIds(tempList).then((musicList) {
        state.items = musicList;
        refresh();
      });
    }
  }

  onRemoveTap(List<String> musicIds) async {
    final status = await DBLogic.to.removeItemFromMenu(menu.id, musicIds);
    if (status == 1) {
      refreshData();
    } else if (status == 2) {
      Get.back();
    }
  }
}
