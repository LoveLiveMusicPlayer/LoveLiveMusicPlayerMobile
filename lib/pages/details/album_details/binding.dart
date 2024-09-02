import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/details/album_details/logic.dart';
import 'package:lovelivemusicplayer/widgets/details_body/logic.dart';

class AlbumDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AlbumDetailController());
    Get.lazyPut(() => DetailsBodyLogic());
  }
}
