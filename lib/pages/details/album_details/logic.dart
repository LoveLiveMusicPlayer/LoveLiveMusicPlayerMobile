import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

class AlbumDetailController extends DetailController {
  Album album = NestedController.to.album;

  @override
  void onInit() {
    state.title = album.albumName!;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
    AppUtils.uploadEvent("AlbumDetailsPage");
  }

  @override
  refreshData() {
    DBLogic.to.findAllMusicsByAlbumId(album.albumId!).then((musicList) {
      state.items = musicList;
      refresh();
    });
  }
}
