import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/moe_girl/logic.dart';

class MoeGirlBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MoeGirlLogic>(MoeGirlLogic());
  }
}
