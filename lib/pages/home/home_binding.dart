import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/drawer/logic.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/pages/home/we_slide/logic.dart';
import 'package:lovelivemusicplayer/pages/player/player/logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WeSlideLogic());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => NestedController());
    Get.lazyPut(() => DrawerLogic());
    Get.lazyPut(() => PageViewLogic());
    Get.lazyPut(() => PlayerPageLogic());
  }
}
