import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';

import '../models/Music.dart';

class GlobalLogic extends SuperController with GetSingleTickerProviderStateMixin {
  /// all、μ's、aqours、niji、liella、combine
  final currentGroup = "all".obs;

  final musicByAllList = <Music>[];
  final musicByUsList = <Music>[];
  final musicByAqoursList = <Music>[];
  final musicByNijiList = <Music>[];
  final musicByLiellaList = <Music>[];
  final musicByCombineList = <Music>[];

  final albumByAllList = <Album>[];
  final albumByUsList = <Album>[];
  final albumByAqoursList = <Album>[];
  final albumByNijiList = <Album>[];
  final albumByLiellaList = <Album>[];
  final albumByCombineList = <Album>[];

  final artistByAllList = <Artist>[];
  final artistByUsList = <Artist>[];
  final artistByAqoursList = <Artist>[];
  final artistByNijiList = <Artist>[];
  final artistByLiellaList = <Artist>[];
  final artistByCombineList = <Artist>[];

  static GlobalLogic get to => Get.find();

  getListSize(int index) {
    switch (index) {
      case 0:
        return checkMusicList().length;
      case 1:
        return checkAlbumList().length;
      case 2:
        return checkArtistList().length;
      default:
        return 6;
    }
  }

  List<Music> checkMusicList() {
    switch (currentGroup.value) {
      case "all":
        return musicByAllList;
      case "μ's":
        return musicByUsList;
      case "aqours":
        return musicByAqoursList;
      case "niji":
        return musicByNijiList;
      case "liella":
        return musicByLiellaList;
      case "combine":
        return musicByCombineList;
      default:
        return [];
    }
  }

  List<Album> checkAlbumList() {
    switch (currentGroup.value) {
      case "all":
        return albumByAllList;
      case "μ's":
        return albumByUsList;
      case "aqours":
        return albumByAqoursList;
      case "niji":
        return albumByNijiList;
      case "liella":
        return albumByLiellaList;
      case "combine":
        return albumByCombineList;
      default:
        return [];
    }
  }

  List<Artist> checkArtistList() {
    switch (currentGroup.value) {
      case "all":
        return artistByAllList;
      case "μ's":
        return artistByUsList;
      case "aqours":
        return artistByAqoursList;
      case "niji":
        return artistByNijiList;
      case "liella":
        return artistByLiellaList;
      case "combine":
        return artistByCombineList;
      default:
        return [];
    }
  }

  Music getMusicByUidAndGroup(String uid, String? group) {
    switch (group) {
      case "μ's":
        return musicByUsList.where((element) => element.uid == uid).first;
      case "aqours":
        return musicByAqoursList.where((element) => element.uid == uid).first;
      case "niji":
        return musicByNijiList.where((element) => element.uid == uid).first;
      case "liella":
        return musicByLiellaList.where((element) => element.uid == uid).first;
      case "combine":
        return musicByCombineList.where((element) => element.uid == uid).first;
      default:
        return musicByAllList.where((element) => element.uid == uid).first;
    }
  }

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
