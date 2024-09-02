import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/logic.dart';
import 'package:lovelivemusicplayer/widgets/details_body/logic.dart';

class MenuDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MenuDetailController());
    Get.lazyPut(() => DetailsBodyLogic());
  }
}
