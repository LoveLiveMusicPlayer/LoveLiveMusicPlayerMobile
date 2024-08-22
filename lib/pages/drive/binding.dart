import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/drive/logic.dart';

class DriveModeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DriveModeLogic>(DriveModeLogic());
  }
}
