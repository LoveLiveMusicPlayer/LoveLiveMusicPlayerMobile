import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/dao/database.dart';
import 'package:lovelivemusicplayer/dao/lyric_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/dao/playlistmusic_dao.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/models/PlayListMusic.dart';

import '../dao/album_dao.dart';
import '../models/Album.dart';
import '../models/FtpMusic.dart';
import '../models/Music.dart';

class DBLogic extends SuperController with GetSingleTickerProviderStateMixin {
  late MusicDatabase database;
  late AlbumDao albumDao;
  late LyricDao lyricDao;
  late MusicDao musicDao;
  late PlayListMusicDao playListMusicDao;
  // 是否是第一次获取持久化播放列表
  bool isInit = true;

  final globalLogic = Get.find<GlobalLogic>();
  final playLogic = Get.find<PlayerLogic>();

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
    playListMusicDao = database.playListMusicDao;
    await findAllListByGroup("all");
    await findAllPlayListMusics();
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
    findAllLoveListByGroup(group);

    GlobalLogic.to.databaseInitOver.value = true;

    SmartDialog.compatible.showToast(
        "专辑: ${allAlbums.length}; 歌曲: ${allMusics.length}",
        time: const Duration(seconds: 5));
  }

  /// 获取我喜欢列表
  findAllLoveListByGroup(String group) {
    final loveList = <Music>[];
    GlobalLogic.to.musicList.where((music) {
      if (group == "all") {
        return music.isLove;
      } else {
        return music.isLove && music.group == group;
      }
    }).forEach((music) {
      loveList.add(music);
    });
    GlobalLogic.to.loveList.value = loveList;
  }

  /// 初始化数据库数据
  Future<void> insertMusicIntoAlbum(DownloadMusic downloadMusic) async {
    final album = await albumDao.findAlbumByUId(downloadMusic.albumUId);
    if (album == null) {
      final _album = Album(
          albumId: downloadMusic.albumUId,
          albumName: downloadMusic.albumName,
          date: downloadMusic.date,
          coverPath: downloadMusic.coverPath,
          category: downloadMusic.category,
          group: downloadMusic.group);
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
          isLove: false);
      await musicDao.insertMusic(_music);
    }
  }

  /// 获取上一次持久化的播放列表并播放
  Future<void> findAllPlayListMusics() async {
    final playList = await playListMusicDao.findAllPlayListMusics();
    final musicIds = <String>[];
    for (var playListMusic in playList) {
      musicIds.add(playListMusic.musicId);
    }
    var willPlayMusicIndex = 0;
    for (var i = 0; i < playList.length; i++) {
      if (playList[i].isPlaying) {
        willPlayMusicIndex = i;
      }
    }
    final musicList = await musicDao.findMusicsByMusicIds(musicIds);
    playLogic.playMusic(musicList, index: willPlayMusicIndex, needPlay: false);
  }

  /// 更新播放列表
  Future<void> updatePlayingList(List<PlayListMusic> playMusics) async {
    if (isInit) {
      isInit = false;
      return;
    }
    if (playMusics.isNotEmpty && !isInit) {
      await playListMusicDao.deleteAllPlayListMusics();
      await playListMusicDao.insertAllPlayListMusics(playMusics);
    }
  }

  /// 通过albumId获取专辑下的全部歌曲
  Future<List<Music>> findAllMusicsByAlbumId(String albumId) async {
    return await musicDao.findAllMusicsByAlbumId(albumId);
  }

  /// 通过musicId获取歌曲
  Future<Music?> findMusicByMusicId(String musicId) async {
    return await musicDao.findMusicByUId(musicId);
  }

  Future<Music> updateLove(Music music) async {
    music.isLove = !music.isLove;
    await musicDao.updateMusic(music);
    GlobalLogic.to.musicList.firstWhere((_music) => _music.musicId == music.musicId).isLove = music.isLove;
    return music;
  }

  /// 清空全部专辑
  clearAllAlbum() async {
    await albumDao.deleteAllAlbums();
    await musicDao.deleteAllMusics();
    await lyricDao.deleteAllLyrics();
    await playListMusicDao.deleteAllPlayListMusics();
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
