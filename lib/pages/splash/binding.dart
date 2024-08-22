import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/splash/logic.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashLogic>(SplashLogic());
  }
}
