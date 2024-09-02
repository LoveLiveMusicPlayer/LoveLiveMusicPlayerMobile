import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

class SingerDetailController extends DetailController {
  Artist artist = NestedController.to.artist;

  @override
  void onInit() {
    state.title = artist.name;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
    AppUtils.uploadEvent("SingerDetailsPage");
  }

  @override
  refreshData() {
    DBLogic.to.findAllMusicsByArtistBin(artist.uid).then((musicList) {
      state.items = musicList;
      refresh();
    });
  }
}
