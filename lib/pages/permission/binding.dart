import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/permission/logic.dart';

class PermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PermissionLogic>(PermissionLogic());
  }
}
