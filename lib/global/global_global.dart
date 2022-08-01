import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';

import '../models/Music.dart';

class GlobalLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  /// all、μ's、Aqours、Nijigasaki、Liella!、Combine
  final currentGroup = "all".obs;
  final databaseInitOver = false.obs;

  final musicList = <Music>[].obs;
  final albumList = <Album>[].obs;
  final artistList = <Artist>[].obs;
  final loveList = <Music>[].obs;
  final menuList = <Menu>[].obs;
  final recentlyList = <Music>[].obs;

  /// 是否正在处理播放逻辑
  var isHandlePlay = false;

  static GlobalLogic get to => Get.find();

  int getListSize(int index, bool isDbInit) {
    if (!isDbInit) {
      return 0;
    }
    switch (index) {
      case 0:
        return musicList.length;
      case 1:
        return albumList.length;
      case 2:
        return artistList.length;
      case 3:
        return loveList.length;
      case 4:
        return menuList.length;
      case 5:
        return recentlyList.length;
      default:
        return 0;
    }
  }

  RxList getList(int index) {
    switch (index) {
      case 0:
        return musicList;
      case 1:
        return albumList;
      case 2:
        return artistList;
      case 3:
        return loveList;
      case 4:
        return menuList;
      case 5:
        return recentlyList;
      default:
        return [].obs;
    }
  }

  setList(int index, List<dynamic> itemList) {
    switch (index) {
      case 0:
        musicList.value = itemList.cast();
        break;
      case 1:
        albumList.value = itemList.cast();
        break;
      case 2:
        artistList.value = itemList.cast();
        break;
      case 3:
        loveList.value = itemList.cast();
        break;
      case 4:
        menuList.value = itemList.cast();
        break;
      case 5:
        recentlyList.value = itemList.cast();
        break;
      default:
        break;
    }
  }

  List<Music> filterMusicListByAlbums(menuIndex) {
    switch (menuIndex) {
      case 0:
        return musicList;
      case 1:
        List<Music> _musicList = [];
        for (var album in albumList) {
          for (var music in musicList) {
            if (music.albumId == album.albumId) {
              _musicList.add(music);
            }
          }
        }
        return _musicList;
      case 3:
        return loveList;
      case 5:
        return recentlyList;
      default:
        return [];
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
