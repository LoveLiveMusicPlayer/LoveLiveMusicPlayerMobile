import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/drawer/logic.dart';

class DrawerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DrawerLogic>(DrawerLogic());
  }
}
