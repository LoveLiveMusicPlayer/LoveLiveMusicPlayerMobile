import 'package:common_utils/common_utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/dao/database.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import '../dao/album_dao.dart';
import '../models/Album.dart';
import '../models/FtpMusic.dart';
import '../models/Music.dart';

class DBLogic extends SuperController with GetSingleTickerProviderStateMixin {
  late MusicDatabase database;
  late AlbumDao albumDao;

  @override
  Future<void> onInit() async {
    database =
        await $FloorMusicDatabase.databaseBuilder('app_database.db').build();
    albumDao = database.albumDao;
    // await parseJson();
    await findAllList();
    super.onInit();
  }

  parseJson() async {
    final data = await rootBundle.loadString("assets/data.json");
    final ftpList = ftpMusicFromJson(data);
    final albumList = <Album>[];
    final musicList = <Music>[];
    for (var album in ftpList) {
      for (var music in album.music) {
        musicList.add(Music(
            uid: music.uid,
            name: music.name,
            albumId: music.albumId,
            albumName: music.albumName,
            coverPath: music.coverPath,
            musicPath: music.musicPath,
            artist: music.artist,
            artistBin: music.artistBin,
            totalTime: music.totalTime,
            jpUrl: music.jpUrl,
            zhUrl: music.zhUrl,
            romaUrl: music.romaUrl));
      }
      albumList.add(Album(
          uid: album.id,
          name: album.name,
          date: album.date,
          coverPath: album.coverPath,
          category: album.category,
          music: musicList,
          group: album.group));
    }
    await albumDao.deleteAllAlbums();
    await albumDao.insertAllAlbums(albumList);
  }

  findAllList() async {
    final allAlbums = await albumDao.findAllAlbums();
    final usAlbums = allAlbums.where((element) => element.group == "μ's").toList();
    final aqoursAlbums = allAlbums.where((element) => element.group == "Aqours").toList();
    final nijiAlbums = allAlbums.where((element) => element.group == "Nijigasaki").toList();
    final liellaAlbums = allAlbums.where((element) => element.group == "Liella!").toList();
    final combineAlbums = allAlbums.where((element) => element.group == "Combine").toList();

    final usMusics = <Music>[];
    final aqoursMusics = <Music>[];
    final nijiMusics = <Music>[];
    final liellaMusics = <Music>[];
    final combineMusics = <Music>[];

    for (var element in usAlbums) {
      usMusics.addAll(element.music);
    }
    for (var element in aqoursAlbums) {
      aqoursMusics.addAll(element.music);
    }
    for (var element in nijiAlbums) {
      nijiMusics.addAll(element.music);
    }
    for (var element in liellaAlbums) {
      liellaMusics.addAll(element.music);
    }
    for (var element in combineAlbums) {
      combineMusics.addAll(element.music);
    }

    GlobalLogic().musicByUsList.addAll(usMusics);
    GlobalLogic().musicByAqoursList.addAll(aqoursMusics);
    GlobalLogic().musicByNijiList.addAll(nijiMusics);
    GlobalLogic().musicByLiellaList.addAll(liellaMusics);
    GlobalLogic().musicByCombineList.addAll(combineMusics);

    GlobalLogic().albumByUsList.addAll(usAlbums);
    GlobalLogic().albumByAqoursList.addAll(aqoursAlbums);
    GlobalLogic().albumByNijiList.addAll(nijiAlbums);
    GlobalLogic().albumByLiellaList.addAll(liellaAlbums);
    GlobalLogic().albumByCombineList.addAll(combineAlbums);
  }

  @override
  void onDetached() {
    LogUtil.e('onDetached');
  }

  @override
  void onInactive() {
    LogUtil.e('onInactive');
  }

  @override
  void onPaused() {
    LogUtil.e('onPaused');
  }

  @override
  void onResumed() {
    LogUtil.e('onResumed');
  }
}
