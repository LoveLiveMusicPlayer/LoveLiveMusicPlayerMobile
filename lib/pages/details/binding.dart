import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DetailController());
  }
}
