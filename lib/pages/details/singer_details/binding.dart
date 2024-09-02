import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/details/singer_details/logic.dart';
import 'package:lovelivemusicplayer/widgets/details_body/logic.dart';

class SingerDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SingerDetailController());
    Get.lazyPut(() => DetailsBodyLogic());
  }
}
