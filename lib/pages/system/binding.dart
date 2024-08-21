import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/system/logic.dart';

class SystemSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SystemSettingLogic>(SystemSettingLogic());
  }
}
