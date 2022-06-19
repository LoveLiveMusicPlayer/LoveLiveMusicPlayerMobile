import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
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
    database = await $FloorMusicDatabase
        .databaseBuilder('app_database.db')
        // .addMigrations([migration1to2])
        .build();
    albumDao = database.albumDao;
    lyricDao = database.lyricDao;
    await findAllList();
    super.onInit();
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

    /// 先清空
    globalLogic.albumByUsList.clear();
    globalLogic.albumByAqoursList.clear();
    globalLogic.albumByNijiList.clear();
    globalLogic.albumByLiellaList.clear();
    globalLogic.albumByCombineList.clear();
    globalLogic.albumByAllList.clear();
    /// 再赋值
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

    /// 先清空
    globalLogic.musicByUsList.clear();
    globalLogic.musicByAqoursList.clear();
    globalLogic.musicByNijiList.clear();
    globalLogic.musicByLiellaList.clear();
    globalLogic.musicByCombineList.clear();
    globalLogic.musicByAllList.clear();
    /// 再赋值
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

    /// 先清空
    globalLogic.artistByUsList.clear();
    globalLogic.artistByAqoursList.clear();
    globalLogic.artistByNijiList.clear();
    globalLogic.artistByLiellaList.clear();
    globalLogic.artistByCombineList.clear();
    globalLogic.artistByAllList.clear();
    /// 再赋值
    globalLogic.artistByUsList.addAll(usArtists);
    globalLogic.artistByAqoursList.addAll(aqoursArtists);
    globalLogic.artistByNijiList.addAll(nijiArtists);
    globalLogic.artistByLiellaList.addAll(liellaArtists);
    globalLogic.artistByCombineList.addAll(combineArtists);
    globalLogic.artistByAllList.addAll(allArtists);

    GlobalLogic.to.databaseInitOver.value = true;

    SmartDialog.showToast("专辑: ${allAlbums.length}; 歌曲: ${allMusics.length}", time: const Duration(seconds: 5));
  }

  insertMusicIntoAlbum(DownloadMusic music) async {
    final albumUId = music.albumUId;
    final album = await albumDao.findAlbumByUId(albumUId);
    final _music = Music(
        uid: music.musicUId,
        name: music.musicName,
        albumId: music.albumUId,
        coverPath: music.coverPath,
        artist: music.artist,
        artistBin: music.artistBin,
        albumName: music.albumName,
        musicPath: music.musicPath,
        totalTime: music.totalTime,
        jpUrl: music.jpUrl,
        zhUrl: music.zhUrl,
        romaUrl: music.romaUrl,
        group: music.group
    );
    if (album == null) {
      final _album = Album(
        uid: music.albumUId,
        name: music.albumName,
        date: music.date,
        coverPath: [music.coverPath],
        category: music.category,
        group: music.group,
        music: [_music]
      );
      albumDao.insertAlbum(_album);
      print(albumToJson(_album));
    } else {
      final hasCurrentMusic = album.music.any((element) => element.uid == music.musicUId);
      if (!hasCurrentMusic) {
        album.coverPath = album.coverPath ?? <String>[];
        album.coverPath?.add(music.coverPath);
        album.music.add(_music);
        albumDao.updateAlbum(album);
        print(albumToJson(album));
      }
    }
    print(musicToJson(_music));
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
