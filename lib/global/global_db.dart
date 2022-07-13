import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/dao/database.dart';
import 'package:lovelivemusicplayer/dao/lyric_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Music.dart';

import '../dao/album_dao.dart';
import '../models/Album.dart';
import '../models/FtpMusic.dart';
import '../models/Music.dart';

class DBLogic extends SuperController with GetSingleTickerProviderStateMixin {
  late MusicDatabase database;
  late AlbumDao albumDao;
  late LyricDao lyricDao;
  late MusicDao musicDao;

  final globalLogic = Get.find<GlobalLogic>();

  static DBLogic get to => Get.find();

  @override
  Future<void> onInit() async {
    database = await $FloorMusicDatabase
        .databaseBuilder('app_database.db')
        // .addMigrations([migration1to2])
        .build();
    albumDao = database.albumDao;
    lyricDao = database.lyricDao;
    musicDao = database.musicDao;
    await findAllListByGroup("all");
    super.onInit();
  }

  Future<void> findAllListByGroup(String group) async {
    print(group);

    /// 设置专辑、歌曲数据
    final allAlbums = <Album>[];
    final allMusics = <Music>[];
    if (group == "all") {
      allAlbums.addAll(await albumDao.findAllAlbums());
      allMusics.addAll(await musicDao.findAllMusics());
    } else {
      allAlbums.addAll(await albumDao.findAllAlbumsByGroup(group));
      allMusics.addAll(await musicDao.findAllMusicsByGroup(group));
    }
    allAlbums.sort((a, b) => a.date!.compareTo(b.date!));

    GlobalLogic.to.albumList.value = allAlbums;
    GlobalLogic.to.musicList.value = allMusics;

    GlobalLogic.to.databaseInitOver.value = true;

    SmartDialog.compatible.showToast(
        "专辑: ${allAlbums.length}; 歌曲: ${allMusics.length}",
        time: const Duration(seconds: 5));
  }

  Future<void> insertMusicIntoAlbum(DownloadMusic downloadMusic) async {
    final album = await albumDao.findAlbumByUId(downloadMusic.albumUId);
    if (album == null) {
      final _album = Album(
          albumId: downloadMusic.albumUId,
          albumName: downloadMusic.albumName,
          date: downloadMusic.date,
          coverPath: downloadMusic.coverPath,
          category: downloadMusic.category,
          group: downloadMusic.group
      );
      await albumDao.insertAlbum(_album);
    }

    final music = await musicDao.findMusicByUId(downloadMusic.musicUId);
    if (music == null) {
      final _music = Music(
          musicId: downloadMusic.musicUId,
          musicName: downloadMusic.musicName,
          albumId: downloadMusic.albumUId,
          coverPath: downloadMusic.coverPath,
          artist: downloadMusic.artist,
          artistBin: downloadMusic.artistBin,
          albumName: downloadMusic.albumName,
          musicPath: downloadMusic.musicPath,
          time: downloadMusic.totalTime,
          jpUrl: downloadMusic.jpUrl,
          zhUrl: downloadMusic.zhUrl,
          romaUrl: downloadMusic.romaUrl,
          group: downloadMusic.group,
          category: downloadMusic.category,
          isLove: false
      );
      await musicDao.insertMusic(_music);
    }
  }

  Future<List<Music>> findAllMusicsByAlbumId(String albumId) async {
    return await musicDao.findAllMusicsByAlbumId(albumId);
  }

  Future<Music?> findMusicByMusicId(String musicId) async {
    return await musicDao.findMusicByUId(musicId);
  }

  clearAllAlbum() async {
    await albumDao.deleteAllAlbums();
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
