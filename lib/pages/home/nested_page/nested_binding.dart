import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';

class NestedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NestedController());
  }
}
