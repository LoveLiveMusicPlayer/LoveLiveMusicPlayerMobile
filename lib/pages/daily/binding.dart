import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/daily/logic.dart';

class DailyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DailyLogic>(DailyLogic());
  }
}
