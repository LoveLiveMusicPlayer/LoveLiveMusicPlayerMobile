import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Album.dart';

import '../models/Music.dart';

class GlobalLogic extends SuperController with GetSingleTickerProviderStateMixin {

  /// all、μ's、aqours、niji、liella、combine
  final currentGroup = "all".obs;

  final musicByUsList = <Music>[].obs;
  final musicByAqoursList = <Music>[].obs;
  final musicByNijiList = <Music>[].obs;
  final musicByLiellaList = <Music>[].obs;
  final musicByCombineList = <Music>[].obs;

  final albumByUsList = <Album>[].obs;
  final albumByAqoursList = <Album>[].obs;
  final albumByNijiList = <Album>[].obs;
  final albumByLiellaList = <Album>[].obs;
  final albumByCombineList = <Album>[].obs;


  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }

}