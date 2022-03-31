import 'package:common_utils/common_utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/dao/database.dart';
import 'package:lovelivemusicplayer/models/Music.dart' as MusicData;
import '../dao/album_dao.dart';
import '../dao/music_dao.dart';
import '../models/Album.dart';
import '../models/FtpMusic.dart';
import '../models/Music.dart';

class DBLogic extends SuperController with GetSingleTickerProviderStateMixin {
  late MusicDatabase database;
  late AlbumDao albumDao;
  late MusicDao musicDao;

  @override
  Future<void> onInit() async {
    database =
        await $FloorMusicDatabase.databaseBuilder('app_database.db').build();
    albumDao = database.albumDao;
    musicDao = database.musicDao;
    // await parseJson();
    await findAllList();
    super.onInit();
  }

  parseJson() async {
    final data = await rootBundle.loadString("assets/data.json");
    final ftpList = ftpMusicFromJson(data);
    final albumList = <Album>[];
    final musicList = <MusicData.Music>[];
    for (var album in ftpList) {
      final musicIds = <String>[];
      for (var music in album.music) {
        musicIds.add(music.id);
        musicList.add(MusicData.Music(
            uid: music.id,
            name: music.name,
            albumId: music.album,
            albumName: music.albumName,
            coverPath: music.coverPath,
            musicPath: music.musicPath,
            artist: music.artist,
            artistBin: music.artistBin,
            totalTime: music.time,
            jpUrl: music.lyric,
            zhUrl: music.trans,
            romaUrl: music.roma));
      }
      albumList.add(Album(
          uid: album.id,
          name: album.name,
          date: album.date,
          coverPath: album.coverPath,
          category: album.category,
          music: musicIds));
    }
    await albumDao.deleteAllAlbums();
    await musicDao.deleteAllMusics();
    await albumDao.insertAllAlbums(albumList);
    await musicDao.insertAllMusics(musicList);
  }

  findAllList() async {
    final albumList = await albumDao.findAllAlbums();
    final musicList = await musicDao.findAllMusics();

    for (var album in albumList) {
      LogUtil.e(albumToJson(album));
    }

    LogUtil.e("----------------------------");

    for (var music in musicList) {
      LogUtil.e(musicToJson(music));
    }
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
