import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/sd/logic.dart';

class SDCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SDCardLogic>(SDCardLogic());
  }
}
