import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/global/global_update.dart';

import 'global_db.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UpdateLogic>(UpdateLogic(), permanent: true);
    Get.put<PlayerLogic>(PlayerLogic(), permanent: true);
    Get.put<DBLogic>(DBLogic(), permanent: true);
  }
}
