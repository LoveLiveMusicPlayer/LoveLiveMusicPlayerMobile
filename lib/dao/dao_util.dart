import 'package:lovelivemusicplayer/dao/album_dao.dart';
import 'package:lovelivemusicplayer/dao/history_dao.dart';
import 'package:lovelivemusicplayer/dao/love_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/history.dart';
import 'package:lovelivemusicplayer/models/love.dart';
import 'package:lovelivemusicplayer/models/music.dart';

extension MusicDaoExt on MusicDao {
  Future<List<Music>> findAllMusics() async {
    return GlobalLogic.to.sortMode.value == "ASC"
        ? await findAllMusicsASC()
        : await findAllMusicsDESC();
  }

  Future<List<Music>> findAllExistMusics() async {
    return GlobalLogic.to.sortMode.value == "ASC"
        ? await findAllExistMusicsASC()
        : await findAllExistMusicsDESC();
  }

  Future<List<Music>> findAllMusicsByGroup(String group) async {
    return GlobalLogic.to.sortMode.value == "ASC"
        ? await findAllMusicsByGroupASC(group)
        : await findAllMusicsByGroupDESC(group);
  }

  Future<List<Music>> findAllExistMusicsByGroup(String group) async {
    return GlobalLogic.to.sortMode.value == "ASC"
        ? await findAllExistMusicsByGroupASC(group)
        : await findAllExistMusicsByGroupDESC(group);
  }
}

extension AlbumDaoExt on AlbumDao {
  String? getCategoryName() {
    final categoryIndex = GlobalLogic.to.albumCategoryIndex.value;
    final isCategoryAll = categoryIndex == 0;
    if (isCategoryAll) return null;
    return GlobalLogic.to.albumCategoryMap[categoryIndex];
  }

  Future<List<Album>> findAllAlbums() async {
    final categoryName = getCategoryName();
    return GlobalLogic.to.sortMode.value == "ASC"
        ? (categoryName == null
            ? await findAllAlbumsASC()
            : await findAllAlbumsByCategoryASC(categoryName))
        : (categoryName == null
            ? await findAllAlbumsDESC()
            : await findAllAlbumsByCategoryDESC(categoryName));
  }

  Future<List<Album>> findAllExistAlbums() async {
    final categoryName = getCategoryName();
    return GlobalLogic.to.sortMode.value == "ASC"
        ? (categoryName == null
            ? await findAllExistAlbumsASC()
            : await findAllExistAlbumsByCategoryASC(categoryName))
        : (categoryName == null
            ? await findAllExistAlbumsDESC()
            : await findAllExistAlbumsByCategoryDESC(categoryName));
  }

  Future<List<Album>> findAllAlbumsByGroup(String group) async {
    final categoryName = getCategoryName();
    return GlobalLogic.to.sortMode.value == "ASC"
        ? (categoryName == null
            ? await findAllAlbumsByGroupASC(group)
            : await findAllAlbumsByGroupAndCategoryASC(group, categoryName))
        : (categoryName == null
            ? await findAllAlbumsByGroupDESC(group)
            : await findAllAlbumsByGroupAndCategoryDESC(group, categoryName));
  }

  Future<List<Album>> findAllExistAlbumsByGroup(String group) async {
    final categoryName = getCategoryName();
    return GlobalLogic.to.sortMode.value == "ASC"
        ? (categoryName == null
            ? await findAllExistAlbumsByGroupASC(group)
            : await findAllExistAlbumsByGroupAndCategoryASC(
                group, categoryName))
        : (categoryName == null
            ? await findAllExistAlbumsByGroupDESC(group)
            : await findAllExistAlbumsByGroupAndCategoryDESC(
                group, categoryName));
  }
}

extension LoveDaoExt on LoveDao {
  Future<List<Love>> findAllLoves() async {
    return GlobalLogic.to.sortMode.value == "ASC"
        ? await findAllLovesASC()
        : await findAllLovesDESC();
  }
}

extension HistoryDaoExt on HistoryDao {
  Future<List<History>> findAllHistorys() async {
    return GlobalLogic.to.sortMode.value == "ASC"
        ? await findAllHistorysASC()
        : await findAllHistorysDESC();
  }
}
