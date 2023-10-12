import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/dao/album_dao.dart';
import 'package:lovelivemusicplayer/dao/artist_dao.dart';
import 'package:lovelivemusicplayer/dao/database.dart';
import 'package:lovelivemusicplayer/dao/history_dao.dart';
import 'package:lovelivemusicplayer/dao/love_dao.dart';
import 'package:lovelivemusicplayer/dao/lyric_dao.dart';
import 'package:lovelivemusicplayer/dao/menu_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/dao/playlist_dao.dart';
import 'package:lovelivemusicplayer/dao/splash_dao.dart';
import 'package:lovelivemusicplayer/eventbus/close_open.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/models/artist_model.dart';
import 'package:lovelivemusicplayer/models/ftp_music.dart';
import 'package:lovelivemusicplayer/models/history.dart';
import 'package:lovelivemusicplayer/models/love.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/play_list_music.dart';
import 'package:lovelivemusicplayer/models/trans_data.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';

class DBLogic extends SuperController with GetSingleTickerProviderStateMixin {
  late MusicDatabase database;
  late AlbumDao albumDao;
  late LyricDao lyricDao;
  late MusicDao musicDao;
  late PlayListMusicDao playListMusicDao;
  late MenuDao menuDao;
  late ArtistDao artistDao;
  late LoveDao loveDao;
  late HistoryDao historyDao;
  late SplashDao splashDao;

  final artistList = <ArtistModel>[];
  final singleMap = <String, String>{};

  final globalLogic = Get.find<GlobalLogic>();
  final playLogic = Get.find<PlayerLogic>();

  static DBLogic get to => Get.find();

  @override
  Future<void> onInit() async {
    database = await $FloorMusicDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([
      migration1to2,
      migration2to3,
      migration3to4,
      migration4to5,
      migration5to6,
      migration6to7,
    ]).build();
    splashDao = database.splashDao;
    albumDao = database.albumDao;
    lyricDao = database.lyricDao;
    musicDao = database.musicDao;
    playListMusicDao = database.playListMusicDao;
    menuDao = database.menuDao;
    artistDao = database.artistDao;
    loveDao = database.loveDao;
    historyDao = database.historyDao;
    CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;

    await checkNeedClearApp();

    await findAllListByGroup(Const.groupAll);
    await PlayerLogic.to.initLoopMode();
    await findAllPlayListMusics();
    if (!hasAIPic) {
      // 没有AI开屏时发送卸载窗口命令
      eventBus.fire(CloseOpen((DateTime.now().millisecondsSinceEpoch)));
    }
    isInitSplashDao = true;
    super.onInit();
  }

  /// 初始化数据库数据
  Future<void> findAllListByGroup(String group) async {
    try {
      /// 设置专辑、歌曲数据
      final allAlbums = <Album>[];
      if (group == Const.groupAll) {
        // 获取全部专辑列表
        final tempAlbumList = <Album>[];
        if (remoteHttp.isEnableHttp()) {
          tempAlbumList
              .addAll(await albumDao.findAllAlbumsByGroup(Const.groupUs));
          tempAlbumList
              .addAll(await albumDao.findAllAlbumsByGroup(Const.groupAqours));
          tempAlbumList
              .addAll(await albumDao.findAllAlbumsByGroup(Const.groupSaki));
          tempAlbumList
              .addAll(await albumDao.findAllAlbumsByGroup(Const.groupLiella));
          tempAlbumList
              .addAll(await albumDao.findAllAlbumsByGroup(Const.groupCombine));
          tempAlbumList.addAll(
              await albumDao.findAllAlbumsByGroup(Const.groupHasunosora));
          tempAlbumList
              .addAll(await albumDao.findAllAlbumsByGroup(Const.groupYohane));
        } else {
          tempAlbumList
              .addAll(await albumDao.findAllExistAlbumsByGroup(Const.groupUs));
          tempAlbumList.addAll(
              await albumDao.findAllExistAlbumsByGroup(Const.groupAqours));
          tempAlbumList.addAll(
              await albumDao.findAllExistAlbumsByGroup(Const.groupSaki));
          tempAlbumList.addAll(
              await albumDao.findAllExistAlbumsByGroup(Const.groupLiella));
          tempAlbumList.addAll(
              await albumDao.findAllExistAlbumsByGroup(Const.groupCombine));
          tempAlbumList.addAll(
              await albumDao.findAllExistAlbumsByGroup(Const.groupHasunosora));
          tempAlbumList.addAll(
              await albumDao.findAllExistAlbumsByGroup(Const.groupYohane));
        }

        allAlbums.addAll(tempAlbumList);

        // 获取全部歌曲列表
        final tempMusicList = <Music>[];
        if (remoteHttp.isEnableHttp()) {
          tempMusicList
              .addAll(await musicDao.findAllMusicsByGroup(Const.groupUs));
          tempMusicList
              .addAll(await musicDao.findAllMusicsByGroup(Const.groupAqours));
          tempMusicList
              .addAll(await musicDao.findAllMusicsByGroup(Const.groupSaki));
          tempMusicList
              .addAll(await musicDao.findAllMusicsByGroup(Const.groupLiella));
          tempMusicList
              .addAll(await musicDao.findAllMusicsByGroup(Const.groupCombine));
          tempMusicList.addAll(
              await musicDao.findAllMusicsByGroup(Const.groupHasunosora));
          tempMusicList
              .addAll(await musicDao.findAllMusicsByGroup(Const.groupYohane));
        } else {
          tempMusicList
              .addAll(await musicDao.findAllExistMusicsByGroup(Const.groupUs));
          tempMusicList.addAll(
              await musicDao.findAllExistMusicsByGroup(Const.groupAqours));
          tempMusicList.addAll(
              await musicDao.findAllExistMusicsByGroup(Const.groupSaki));
          tempMusicList.addAll(
              await musicDao.findAllExistMusicsByGroup(Const.groupLiella));
          tempMusicList.addAll(
              await musicDao.findAllExistMusicsByGroup(Const.groupCombine));
          tempMusicList.addAll(
              await musicDao.findAllExistMusicsByGroup(Const.groupHasunosora));
          tempMusicList.addAll(
              await musicDao.findAllExistMusicsByGroup(Const.groupYohane));
        }
        GlobalLogic.to.musicList.value = tempMusicList;
        final artistArr = await artistDao.findAllArtists();
        artistArr.sort((a, b) => AppUtils.comparePeopleNumber(a.uid, b.uid));
        var mergeArtistList = mergeArtists(artistArr);
        GlobalLogic.to.artistList.value = mergeArtistList;
      } else {
        if (remoteHttp.isEnableHttp()) {
          allAlbums.addAll(await albumDao.findAllAlbumsByGroup(group));
          GlobalLogic.to.musicList.value =
              await musicDao.findAllMusicsByGroup(group);
        } else {
          allAlbums.addAll(await albumDao.findAllExistAlbumsByGroup(group));
          GlobalLogic.to.musicList.value =
              await musicDao.findAllExistMusicsByGroup(group);
        }
        final artistArr = await artistDao.findAllArtistsByGroup(group);
        artistArr.sort((a, b) => AppUtils.comparePeopleNumber(a.uid, b.uid));
        GlobalLogic.to.artistList.value = artistArr;
      }
      GlobalLogic.to.albumList.value = allAlbums;
      await findAllHistoryListByGroup(group);
      await findAllLoveListByGroup(group);
      await findAllMenuList();

      GlobalLogic.to.databaseInitOver.value = true;
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
    try {
      scrollToTop(HomeController.scrollController1);
      scrollToTop(HomeController.scrollController2);
      scrollToTop(HomeController.scrollController3);
      scrollToTop(HomeController.scrollController4);
      scrollToTop(HomeController.scrollController5);
      scrollToTop(HomeController.scrollController6);
    } catch (_) {}
  }

  List<Artist> mergeArtists(List<Artist> artists) {
    Map<String, Artist> mergedMap = {};

    for (var artist in artists) {
      if (mergedMap.containsKey(artist.uid)) {
        mergedMap[artist.uid]!.music.addAll(artist.music);
      } else {
        mergedMap[artist.uid] = artist;
      }
    }

    List<Artist> mergedList = mergedMap.values.toList();

    return mergedList;
  }

  /// 导入数据
  Future<void> importMusic(DownloadMusic downloadMusic) async {
    try {
      final album = await findAlbumById(downloadMusic.albumUId);
      if (album == null) {
        final mAlbum = Album(
            albumId: downloadMusic.albumUId,
            albumName: downloadMusic.albumName,
            date: downloadMusic.date,
            coverPath: downloadMusic.baseUrl + downloadMusic.coverPath,
            category: downloadMusic.category,
            group: downloadMusic.group,
            existFile: downloadMusic.existFile);
        await albumDao.insertAlbum(mAlbum);
      } else if (album.existFile == false && downloadMusic.existFile) {
        album.existFile = true;
        await albumDao.updateAlbum(album);
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
            neteaseId: downloadMusic.neteaseId,
            time: downloadMusic.totalTime,
            group: downloadMusic.group,
            date: downloadMusic.date,
            category: downloadMusic.category,
            existFile: downloadMusic.existFile,
            isLove: false);
        await musicDao.insertMusic(mMusic);
        if (artistList.isEmpty) {
          await downloadArtistModelList();
          for (var artist in artistList) {
            final singleModel = artist.m;
            if (singleModel != null) {
              singleMap[singleModel] = artist.v;
            }
          }
        }
        final artistModelList =
            AppUtils.parseArtistBin(mMusic.artistBin, artistList, singleMap);
        for (var artistModel in artistModelList) {
          var artist = await artistDao.findArtistByArtistBinAndGroup(
              artistModel.v, mMusic.group!);

          if (artist == null) {
            artist = Artist(
                uid: artistModel.v,
                name: artistModel.k,
                photo:
                    "${Const.dataOssUrl}LLMP/artist_webp/${artistModel.v}.webp",
                music: [mMusic.musicId!],
                group: mMusic.group!);
            await artistDao.insertArtistWithId(artist);
          } else {
            artist.music.add(mMusic.musicId!);
            await artistDao.updateArtist(artist);
          }
        }
      } else if (music.existFile == false && downloadMusic.existFile) {
        music.existFile = true;
        await musicDao.updateMusic(music);
      }
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  Future<void> downloadArtistModelList() async {
    final res =
        await Network.getSync(Const.artistModelUrl, isShowDialog: false);
    if (res is List) {
      artistList.addAll(artistFromJson(jsonEncode(res)));
    }
  }

  /// 批量通过musicId查找歌曲列表
  Future<List<Music>> findMusicByMusicIds(List<String> musicList) async {
    final arr = [];
    for (var element in musicList) {
      arr.add("'$element'");
    }
    final joinStr = "',${musicList.join(",")},', ',' || musicId || ','";
    List<
        Map<String,
            dynamic>> tempList = await DBLogic.to.database.database.rawQuery(
        'SELECT * FROM Music WHERE musicId IN (${arr.join(",")}) ORDER BY INSTR($joinStr)');
    final musicArr = <Music>[];
    for (var row in tempList) {
      final existFile = (row['existFile'] as int?) == 1;
      if (!remoteHttp.isEnableHttp() && !existFile) {
        continue;
      }
      final music = Music(
          musicId: row['musicId'] as String?,
          musicName: row['musicName'] as String?,
          artist: row['artist'] as String?,
          artistBin: row['artistBin'] as String?,
          albumId: row['albumId'] as String?,
          albumName: row['albumName'] as String?,
          coverPath: row['coverPath'] as String?,
          musicPath: row['musicPath'] as String?,
          time: row['time'] as String?,
          category: row['category'] as String?,
          group: row['group'] as String?,
          baseUrl: row['baseUrl'] as String?,
          date: row['date'] as String?,
          timestamp: row['timestamp'] as int,
          isLove: (row['isLove'] as int) == 1,
          neteaseId: row['neteaseId'] as String?,
          existFile: existFile);
      musicArr.add(music);
    }
    return musicArr;
  }

  /****************  Album  ****************/

  /// 根据albumUId获取专辑
  Future<Album?> findAlbumById(String uid) async {
    return await albumDao.findAlbumByUId(uid);
  }

  /// 清空歌曲数据
  Future<void> clearAllMusic() async {
    try {
      await albumDao.deleteAllAlbums();
      await musicDao.deleteAllMusics();
      await artistDao.deleteAllArtists();
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  /// 检查是否需要清空APP数据
  Future<void> checkNeedClearApp() async {
    // 获取上一次版本号
    final oldVersion =
        await SpUtil.getString(Const.spForceRemoveVersion, "1.0.0");
    // 比较上一次记录的版本号与当前APP版本，判断是否进来了一个新版本
    final isNewVersion = AppUtils.compareVersion(oldVersion, appVersion);
    if (isNewVersion) {
      // 如果是新版本
      if (needClearApp) {
        // 需要清理APP
        await clearAllMusic();
        await clearAllUserData();
        await SpUtil.clear();
      }
      // 无论如何都要将版本号记录在本地SP
      await SpUtil.put(Const.spForceRemoveVersion, appVersion);
    }
  }

  /// 清空用户数据
  Future<void> clearAllUserData() async {
    try {
      await SpUtil.clear();
      await menuDao.deleteAllMenus();
      await loveDao.deleteAllLoves();
      await historyDao.deleteAllHistorys();
      await splashDao.deleteAllSplashUrls();
      await playListMusicDao.deleteAllPlayListMusics();
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  /// 通过albumId获取专辑下的全部歌曲
  Future<List<Music>> findAllMusicsByAlbumId(String albumId) async {
    if (remoteHttp.isEnableHttp()) {
      return await musicDao.findAllMusicsByAlbumId(albumId);
    }
    return await musicDao.findAllExistMusicsByAlbumId(albumId);
  }

  /// 通过musicUId获取歌曲
  Future<Music?> findMusicById(String uid) async {
    return await musicDao.findMusicByUId(uid);
  }

  /****************  History  **************/

  /// 更新歌曲最后一次的播放时间
  Future<void> refreshMusicTimestamp(String musicId) async {
    final history = await historyDao.findHistoryById(musicId);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (history == null) {
      await historyDao
          .insertHistory(History(musicId: musicId, timestamp: timestamp));
    } else {
      history.timestamp = timestamp;
      await historyDao.updateHistory(history);
    }
    final recentlyList = await historyDao.findAllHistorys();
    final tempList = <Music>[];
    for (var history in recentlyList) {
      for (var music in GlobalLogic.to.musicList) {
        if (music.musicId == history.musicId) {
          tempList.add(music);
        }
      }
    }
    GlobalLogic.to.recentList.value = tempList;
  }

  Future<void> findAllHistoryListByGroup(String group) async {
    final historyList = await historyDao.findAllHistorys();
    final tempList = <Music>[];
    for (var history in historyList) {
      for (var music in GlobalLogic.to.musicList) {
        if (group == Const.groupAll || group == music.group) {
          if (music.musicId == history.musicId) {
            tempList.add(music);
          }
        }
      }
    }
    GlobalLogic.to.recentList.value = tempList;
  }

  /****************  Menu  ****************/

  /// 新增一个歌单
  Future<bool> addMenu(String name, List<String> musicIds) async {
    try {
      final idList = <int>[];
      Future.forEach<Menu>(await menuDao.findAllMenus(), (menu) {
        idList.add(menu.id);
      });
      final id = AppUtils.calcSmallAtIntArr(idList);
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
      Log4f.i(msg: e.toString());
    }
    return false;
  }

  /// 获取歌单列表
  Future<void> findAllMenuList() async {
    final menuList = await menuDao.findAllMenus();
    GlobalLogic.to.menuList.value = menuList;
  }

  /// 向歌单添加歌曲
  Future<bool> insertToMenu(int menuId, List<String> musicIds) async {
    try {
      var menu = await menuDao.findMenuById(menuId);
      if (menu == null) {
        return false;
      }
      if (menu.music.isEmpty) {
        menu.music = musicIds;
      } else {
        final insertList = <String>[];
        for (var musicId in musicIds) {
          if (!menu.music.contains(musicId)) {
            insertList.add(musicId);
          }
        }
        menu.music.addAll(insertList);
      }
      await menuDao.updateMenu(menu);
      await findAllMenuList();
      return true;
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
    return false;
  }

  /// 修改歌单名字
  Future<void> updateMenuName(String name, int menuId) async {
    try {
      Menu? menu = await menuDao.findMenuById(menuId);
      if (menu != null) {
        menu.name = name;
        await menuDao.updateMenu(menu);
        await findAllMenuList();
      }
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  /// 删除歌单中的歌曲
  /// @param menuId 歌单id
  /// @param musicIds 要删除的歌曲id列表
  /// @return 1: 刷新界面 ;2: 需要返回上一页
  Future<int> removeItemFromMenu(int menuId, List<String> musicIds) async {
    try {
      var menu = await menuDao.findMenuById(menuId);
      if (menu == null) {
        return -1;
      }
      final musicIdList = menu.music;
      if (musicIdList.isEmpty) {
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
        menu.music.clear();
        menu.music.addAll(tempList);
        await menuDao.updateMenu(menu);
        await findAllMenuList();
        return 1;
      }
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
    return -1;
  }

  /// 删除歌单
  Future<void> deleteMenuById(int menuId) async {
    try {
      await menuDao.deleteMenuById(menuId);
      await findAllMenuList();
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  /****************  PlayList  ****************/

  /// 获取上一次持久化的播放列表并播放
  Future<void> findAllPlayListMusics() async {
    try {
      final playList = await playListMusicDao.findAllPlayListMusics();
      if (playList.isEmpty) {
        return;
      }
      final musicIds = <String>[];
      var willPlayMusicIndex = 0;
      for (var i = 0; i < playList.length; i++) {
        musicIds.add(playList[i].musicId);
        if (playList[i].isPlaying) {
          willPlayMusicIndex = i;
        }
      }
      final musicList = await findMusicByMusicIds(musicIds);
      if (musicList.isNotEmpty) {
        playLogic.playMusic(musicList,
            mIndex: willPlayMusicIndex, needPlay: false);
      }
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  /// 更新播放列表
  Future<void> updatePlayingList(List<PlayListMusic> playMusics) async {
    try {
      if (playMusics.isNotEmpty) {
        Carplay.parse4PlayList(playMusics);
        await playListMusicDao.deleteAllPlayListMusics();
        await playListMusicDao.insertAllPlayListMusics(playMusics);
      }
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  /****************  Love  ****************/

  /// 获取我喜欢列表
  Future<void> findAllLoveListByGroup(String group) async {
    try {
      final loveList = <Music>[];
      var allLoves = await DBLogic.to.loveDao.findAllLoves();
      await Future.forEach<Love>(allLoves, (love) async {
        final music = await DBLogic.to.musicDao.findMusicByUId(love.musicId);
        if (music != null) {
          if (group == Const.groupAll || music.group == group) {
            music.isLove = true;
            if ((remoteHttp.isEnableHttp() || (music.existFile == true))) {
              loveList.add(music);
            }
          }
        }
      });
      GlobalLogic.to.loveList.value = loveList;
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
  }

  /// 更新当前歌曲的喜欢状态
  Future<Music?> updateLove(Music music, {bool? isLove}) async {
    try {
      music.isLove = isLove ?? !music.isLove;
      if (music.isLove) {
        final love = await loveDao.findLoveById(music.musicId!);
        if (love == null) {
          await loveDao.insertLove(Love(
              musicId: music.musicId!,
              timestamp: DateTime.now().millisecondsSinceEpoch));
        }
      } else {
        await loveDao.deleteLoveById(music.musicId!);
      }
      GlobalLogic.to.musicList
          .firstWhere((mMusic) => mMusic.musicId == music.musicId)
          .isLove = music.isLove;
      return music;
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
    return null;
  }

  /// 更新歌曲列表中全部的喜欢状态
  Future<void> updateLoveList(List<Music> musicList, bool changeStatus) async {
    return await Future.forEach<Music>(musicList, (music) async {
      await updateLove(music, isLove: changeStatus);
    });
  }

  ///****************  Artist  ****************/

  Future<List<Music>> findAllMusicsByArtistBin(String artistBin) async {
    final Artist? artist;
    final musicList = <String>[];
    if (GlobalLogic.to.currentGroup.value == Const.groupAll) {
      final artistList = await artistDao.findArtistByArtistBin(artistBin);
      for (var artist in artistList) {
        if (artist != null) {
          musicList.addAll(artist.music);
        }
      }
    } else {
      artist = await artistDao.findArtistByArtistBinAndGroup(
          artistBin, GlobalLogic.to.currentGroup.value);
      if (artist != null) {
        musicList.addAll(artist.music);
      }
    }

    return await findMusicByMusicIds(musicList);
  }

  scrollToTop(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  ///****************  Transfer  ****************/

  Future<TransData> getTransPhoneData(
      {bool needMenuList = false, bool isCover = false}) async {
    final menuList = <TransMenu>[];
    final loveList = await loveDao.findAllLoves();
    if (needMenuList) {
      for (var menu in GlobalLogic.to.menuList) {
        if (!isCover && menu.id <= 100) {
          // 非全量覆盖，则过滤掉电脑端的歌单
          continue;
        }
        menuList.add(TransMenu(
            menuId: menu.id,
            musicList: menu.music,
            name: menu.name,
            date: menu.date));
      }
    }
    return TransData(love: loveList, menu: menuList, isCover: isCover);
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
