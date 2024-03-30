import 'package:lovelivemusicplayer/dao/history_dao.dart';
import 'package:lovelivemusicplayer/dao/love_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/history.dart';
import 'package:lovelivemusicplayer/models/love.dart';
import 'package:lovelivemusicplayer/models/music.dart';

extension MusicDaoExt on MusicDao {
  Future<List<Music>> findAllMusics() async {
    return sortMode.value == "ASC"
        ? await findAllMusicsASC()
        : await findAllMusicsDESC();
  }

  Future<List<Music>> findAllExistMusics() async {
    return sortMode.value == "ASC"
        ? await findAllExistMusicsASC()
        : await findAllExistMusicsDESC();
  }

  Future<List<Music>> findAllMusicsByGroup(String group) async {
    return sortMode.value == "ASC"
        ? await findAllMusicsByGroupASC(group)
        : await findAllMusicsByGroupDESC(group);
  }

  Future<List<Music>> findAllExistMusicsByGroup(String group) async {
    return sortMode.value == "ASC"
        ? await findAllExistMusicsByGroupASC(group)
        : await findAllExistMusicsByGroupDESC(group);
  }
}

extension LoveDaoExt on LoveDao {
  Future<List<Love>> findAllLoves() async {
    return sortMode.value == "ASC"
        ? await findAllLovesASC()
        : await findAllLovesDESC();
  }
}

extension HistoryDaoExt on HistoryDao {
  Future<List<History>> findAllHistorys() async {
    return sortMode.value == "ASC"
        ? await findAllHistorysASC()
        : await findAllHistorysDESC();
  }
}
