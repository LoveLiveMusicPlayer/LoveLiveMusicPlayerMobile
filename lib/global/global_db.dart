import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/dao/database.dart';
import 'package:lovelivemusicplayer/dao/lyric_dao.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import '../dao/album_dao.dart';
import '../models/Album.dart';
import '../models/FtpMusic.dart';
import '../models/Music.dart';

class DBLogic extends SuperController with GetSingleTickerProviderStateMixin {
  late MusicDatabase database;
  late AlbumDao albumDao;
  late LyricDao lyricDao;

  final globalLogic = Get.find<GlobalLogic>();

  static DBLogic get to => Get.find();

  @override
  Future<void> onInit() async {
    database =
        await $FloorMusicDatabase
            .databaseBuilder('app_database.db')
            .addMigrations([migration1to2])
            .build();
    albumDao = database.albumDao;
    lyricDao = database.lyricDao;
    final allAlbums = await albumDao.findAllAlbums();
    if (allAlbums.isEmpty) {
      await parseJson();
    }
    await findAllList();
    super.onInit();
  }

  parseJson() async {
    final data = await rootBundle.loadString("assets/data.json");
    final ftpList = ftpMusicFromJson(data);
    final albumList = <Album>[];
    for (var album in ftpList) {
      final musicList = <Music>[];
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
    /// 设置专辑数据
    final allAlbums = await albumDao.findAllAlbums();
    final usAlbums =
        allAlbums.where((element) => element.group == "μ's").toList();
    final aqoursAlbums =
        allAlbums.where((element) => element.group == "Aqours").toList();
    final nijiAlbums =
        allAlbums.where((element) => element.group == "Nijigasaki").toList();
    final liellaAlbums =
        allAlbums.where((element) => element.group == "Liella!").toList();
    final combineAlbums =
        allAlbums.where((element) => element.group == "Combine").toList();

    globalLogic.albumByUsList.addAll(usAlbums);
    globalLogic.albumByAqoursList.addAll(aqoursAlbums);
    globalLogic.albumByNijiList.addAll(nijiAlbums);
    globalLogic.albumByLiellaList.addAll(liellaAlbums);
    globalLogic.albumByCombineList.addAll(combineAlbums);
    globalLogic.albumByAllList.addAll(allAlbums);

    /// 设置歌曲数据
    final allMusics = <Music>[];
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

    allMusics.addAll(usMusics);
    allMusics.addAll(aqoursMusics);
    allMusics.addAll(nijiMusics);
    allMusics.addAll(liellaMusics);
    allMusics.addAll(combineMusics);

    globalLogic.musicByUsList.addAll(usMusics);
    globalLogic.musicByAqoursList.addAll(aqoursMusics);
    globalLogic.musicByNijiList.addAll(nijiMusics);
    globalLogic.musicByLiellaList.addAll(liellaMusics);
    globalLogic.musicByCombineList.addAll(combineMusics);
    globalLogic.musicByAllList.addAll(allMusics);

    /// 设置歌手数据
    final allArtists = <Artist>[];
    final usArtists = <Artist>[];
    final aqoursArtists = <Artist>[];
    final nijiArtists = <Artist>[];
    final liellaArtists = <Artist>[];
    final combineArtists = <Artist>[];

    globalLogic.artistByUsList.addAll(usArtists);
    globalLogic.artistByAqoursList.addAll(aqoursArtists);
    globalLogic.artistByNijiList.addAll(nijiArtists);
    globalLogic.artistByLiellaList.addAll(liellaArtists);
    globalLogic.artistByCombineList.addAll(combineArtists);
    globalLogic.artistByAllList.addAll(allArtists);

    GlobalLogic.to.databaseInitOver.value = true;
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
