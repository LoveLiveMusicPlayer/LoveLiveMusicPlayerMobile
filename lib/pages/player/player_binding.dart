import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/player/player_logic.dart';

class PlayerBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<PlayerLogic>(PlayerLogic(), permanent: true);
  }
}