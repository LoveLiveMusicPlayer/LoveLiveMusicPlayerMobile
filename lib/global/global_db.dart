import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/dao/album_dao.dart';
import 'package:lovelivemusicplayer/dao/database.dart';
import 'package:lovelivemusicplayer/dao/lyric_dao.dart';
import 'package:lovelivemusicplayer/dao/menu_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/dao/playlistmusic_dao.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/start_event.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/models/PlayListMusic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

class DBLogic extends SuperController with GetSingleTickerProviderStateMixin {
  late MusicDatabase database;
  late AlbumDao albumDao;
  late LyricDao lyricDao;
  late MusicDao musicDao;
  late PlayListMusicDao playListMusicDao;
  late MenuDao menuDao;

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
    menuDao = database.menuDao;
    CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
    AppUtils.removeNetImageCache(
        "https://video-file-upload.oss-cn-hangzhou.aliyuncs.com/LLMP/artist/120.jpg");
    await findAllListByGroup("all");
    await findAllPlayListMusics();
    await Future.delayed(const Duration(seconds: 1));
    eventBus.fire(StartEvent((DateTime.now().millisecondsSinceEpoch)));
    super.onInit();
  }

  Future<void> findAllListByGroup(String group) async {
    try {
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
      await findAllArtistListByGroup(group);
      await findAllMenuList();

      GlobalLogic.to.databaseInitOver.value = true;
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
    try {
      scrollToTop(HomeController.to.scrollController1);
      scrollToTop(HomeController.to.scrollController2);
      scrollToTop(HomeController.to.scrollController3);
      scrollToTop(HomeController.to.scrollController4);
      scrollToTop(HomeController.to.scrollController5);
      scrollToTop(HomeController.to.scrollController6);
    } catch (e) {}
  }

  scrollToTop(ScrollController scrollController) {
    try {
      scrollController.jumpTo(0);
    } catch (e) {}
  }

  /// 获取我喜欢列表
  findAllLoveListByGroup(String group) {
    try {
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
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  findAllArtistListByGroup(String group) async {
    try {
      final List<Map<String, Object?>> tempList;
      if (group == "all") {
        tempList = await database.database.rawQuery(
            "SELECT artist, artistBin, COUNT(musicId) as count FROM Music GROUP BY artistBin");
      } else {
        tempList = await database.database.rawQuery(
            "SELECT artist, artistBin, COUNT(musicId) as count FROM Music WHERE `group` = :group GROUP BY artistBin",
            <dynamic>[group]);
      }
      final artistList = <Artist>[];
      for (var element in tempList) {
        String name = element['artist'].toString();
        String artistBin = element['artistBin'].toString();
        int count = int.parse(element['count'].toString());
        artistList.add(Artist(
            name: name,
            artistBin: artistBin,
            photo: "${Const.ossUrl}LLMP/artist/$artistBin.jpg",
            count: count));
      }
      GlobalLogic.to.artistList.value = artistList;
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  Future<List<Music>> findAllMusicByArtistBin(String artistBin) async {
    return musicDao.findAllMusicsByArtistBin(artistBin);
  }

  /// 获取歌单列表
  findAllMenuList() async {
    final menuList = await menuDao.findAllMenus();
    GlobalLogic.to.menuList.value = menuList;
  }

  /// 初始化数据库数据
  Future<void> insertMusicIntoAlbum(DownloadMusic downloadMusic) async {
    try {
      final album = await findAlbumById(downloadMusic.albumUId);
      if (album == null) {
        final mAlbum = Album(
            albumId: downloadMusic.albumUId,
            albumName: downloadMusic.albumName,
            date: downloadMusic.date,
            coverPath: downloadMusic.baseUrl + downloadMusic.coverPath,
            category: downloadMusic.category,
            group: downloadMusic.group);
        await albumDao.insertAlbum(mAlbum);
      }
      final music = await findMusicById(downloadMusic.musicUId);
      if (music == null) {
        final mMusic = Music(
            musicId: downloadMusic.musicUId,
            musicName: downloadMusic.musicName,
            albumId: downloadMusic.albumUId,
            coverPath: downloadMusic.coverPath,
            artist: downloadMusic.artist,
            artistBin: downloadMusic.artistBin,
            albumName: downloadMusic.albumName,
            musicPath: downloadMusic.musicPath,
            baseUrl: downloadMusic.baseUrl,
            time: downloadMusic.totalTime,
            group: downloadMusic.group,
            category: downloadMusic.category,
            isLove: false);
        await musicDao.insertMusic(mMusic);
      }
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  Future<Album?> findAlbumById(String uid) async {
    return await albumDao.findAlbumByUId(uid);
  }

  Future<Music?> findMusicById(String uid) async {
    return await musicDao.findMusicByUId(uid);
  }

  Future<void> deleteMenuById(int menuId) async {
    try {
      await menuDao.deleteMenuById(menuId);
      await findAllMenuList();
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  Future<void> updateMenuName(String name, int menuId) async {
    try {
      Menu? menu = await menuDao.findMenuById(menuId);
      if (menu != null) {
        menu.name = name;
        await menuDao.updateMenu(menu);
        await findAllMenuList();
      }
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  /// 获取上一次持久化的播放列表并播放
  Future<void> findAllPlayListMusics() async {
    try {
      final playList = await playListMusicDao.findAllPlayListMusics();
      final musicIds = <String>[];
      var willPlayMusicIndex = 0;
      for (var i = 0; i < playList.length; i++) {
        musicIds.add(playList[i].musicId);
        if (playList[i].isPlaying) {
          willPlayMusicIndex = i;
        }
      }

      final musicList = await musicDao.findMusicsByMusicIds(musicIds);
      if (musicList.isNotEmpty) {
        playLogic.playMusic(musicList,
            index: willPlayMusicIndex, needPlay: false);
      }
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  /// 更新播放列表
  Future<void> updatePlayingList(List<PlayListMusic> playMusics) async {
    try {
      if (playMusics.isNotEmpty) {
        await playListMusicDao.deleteAllPlayListMusics();
        await playListMusicDao.insertAllPlayListMusics(playMusics);
      }
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
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

  /// 更新当前歌曲的喜欢状态
  Future<Music?> updateLove(Music music, {bool? isLove}) async {
    try {
      music.isLove = isLove ?? !music.isLove;
      await musicDao.updateMusic(music);
      GlobalLogic.to.musicList
          .firstWhere((mMusic) => mMusic.musicId == music.musicId)
          .isLove = music.isLove;
      return music;
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
    return null;
  }

  Future<void> updateLoveList(List<Music> musicList, bool changeStatus) async {
    try {
      final changeIdList = <String>[];
      for (var music in musicList) {
        if (music.isLove != changeStatus) {
          changeIdList.add(music.musicId!);
        }
      }
      await musicDao.updateLoveStatus(changeStatus, changeIdList);
      GlobalLogic.to.musicList
          .where((music) => changeIdList.contains(music.musicId))
          .forEach((element) {
        element.isLove = changeStatus;
      });
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  /// 新增一个歌单
  Future<bool> addMenu(String name, List<String> musicIds) async {
    try {
      final idList = await menuDao.findMenuIds() ?? [];
      final id = calcSmallAtIntArr(idList);
      if (id == -1) {
        return false;
      }
      final menu = Menu(
          id: id,
          date: DateUtil.formatDate(DateTime.now(), format: DateFormats.y_mo_d),
          name: name,
          music: musicIds);
      await menuDao.insertMenu(menu);
      await findAllMenuList();
      return true;
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
    return false;
  }

  /// 向歌单添加歌曲
  Future<bool> insertToMenu(int menuId, List<String> musicIds) async {
    try {
      var menu = await menuDao.findMenuById(menuId);
      if (menu == null) {
        return false;
      }
      if (menu.music == null) {
        menu.music = musicIds;
      } else {
        final insertList = <String>[];
        for (var musicId in musicIds) {
          if (!menu.music!.contains(musicId)) {
            insertList.add(musicId);
          }
        }
        menu.music!.addAll(insertList);
      }
      await menuDao.updateMenu(menu);
      await findAllMenuList();
      return true;
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
    return false;
  }

  /// 删除歌单中的歌曲
  /// @param 歌单id
  /// @param 要删除的歌曲id列表
  /// @return 1: 刷新界面 ;2: 需要返回上一页
  Future<int> removeItemFromMenu(int menuId, List<String> musicIds) async {
    try {
      var menu = await menuDao.findMenuById(menuId);
      if (menu == null) {
        return -1;
      }
      final musicIdList = menu.music;
      if (musicIdList == null || musicIdList.isEmpty) {
        return -1;
      }
      final tempList = <String>[];
      for (var musicId in musicIdList) {
        if (!musicIds.contains(musicId)) {
          tempList.add(musicId);
        }
      }
      if (tempList.isEmpty) {
        await menuDao.deleteMenuById(menuId);
        await findAllMenuList();
        return 2;
      } else {
        menu.music?.clear();
        menu.music?.addAll(tempList);
        await menuDao.updateMenu(menu);
        await findAllMenuList();
        return 1;
      }
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
    return -1;
  }

  /// 清空全部专辑
  clearAllAlbum() async {
    try {
      await albumDao.deleteAllAlbums();
      await musicDao.deleteAllMusics();
      await lyricDao.deleteAllLyrics();
      await playListMusicDao.deleteAllPlayListMusics();
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  /// 计算101...200中，数组内不存在的最小值
  int calcSmallAtIntArr(List<int> idList) {
    var result = -1;
    idList.sort();
    for (var i = 101; i <= 200; i++) {
      if (!idList.contains(i)) {
        result = i;
        break;
      }
    }
    return result;
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
