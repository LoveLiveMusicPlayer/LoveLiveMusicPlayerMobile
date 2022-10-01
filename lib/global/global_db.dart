import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/dao/album_dao.dart';
import 'package:lovelivemusicplayer/dao/artist_dao.dart';
import 'package:lovelivemusicplayer/dao/database.dart';
import 'package:lovelivemusicplayer/dao/lyric_dao.dart';
import 'package:lovelivemusicplayer/dao/menu_dao.dart';
import 'package:lovelivemusicplayer/dao/music_dao.dart';
import 'package:lovelivemusicplayer/dao/playlist_dao.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/start_event.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/ArtistModel.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/models/PlayListMusic.dart';
import 'package:lovelivemusicplayer/models/TransData.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

class DBLogic extends SuperController with GetSingleTickerProviderStateMixin {
  late MusicDatabase database;
  late AlbumDao albumDao;
  late LyricDao lyricDao;
  late MusicDao musicDao;
  late PlayListMusicDao playListMusicDao;
  late MenuDao menuDao;
  late ArtistDao artistDao;

  final artistList = <ArtistModel>[];
  final singleMap = <String, String>{};

  final globalLogic = Get.find<GlobalLogic>();
  final playLogic = Get.find<PlayerLogic>();

  static DBLogic get to => Get.find();

  @override
  Future<void> onInit() async {
    database = await $FloorMusicDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2]).build();
    albumDao = database.albumDao;
    lyricDao = database.lyricDao;
    musicDao = database.musicDao;
    playListMusicDao = database.playListMusicDao;
    menuDao = database.menuDao;
    artistDao = database.artistDao;
    CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
    await findAllListByGroup(Const.groupAll);
    await findAllPlayListMusics();
    await Future.delayed(const Duration(seconds: 1));
    eventBus.fire(StartEvent((DateTime.now().millisecondsSinceEpoch)));
    super.onInit();
    PlayerLogic.to.initLoopMode();
  }

  /// 初始化数据库数据
  Future<void> findAllListByGroup(String group) async {
    try {
      /// 设置专辑、歌曲数据
      final allAlbums = <Album>[];
      if (group == Const.groupAll) {
        // 获取全部专辑列表
        final tempAlbumList = <Album>[];
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
        allAlbums.addAll(tempAlbumList);

        // 获取全部歌曲列表
        final tempMusicList = <Music>[];
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
        GlobalLogic.to.musicList.value = tempMusicList;
        final artistArr = await artistDao.findAllArtists();
        artistArr.sort((a, b) => AppUtils.comparePeopleNumber(a.uid, b.uid));
        GlobalLogic.to.artistList.value = artistArr;
      } else {
        allAlbums.addAll(await albumDao.findAllAlbumsByGroup(group));
        GlobalLogic.to.musicList.value =
            await musicDao.findAllMusicsByGroup(group);
        final artistArr = await artistDao.findAllArtistsByGroup(group);
        artistArr.sort((a, b) => AppUtils.comparePeopleNumber(a.uid, b.uid));
        GlobalLogic.to.artistList.value = artistArr;
      }
      GlobalLogic.to.recentList.value = await musicDao.findRecentMusics();
      GlobalLogic.to.albumList.value = allAlbums;

      findAllLoveListByGroup(group);
      await findAllMenuList();

      GlobalLogic.to.databaseInitOver.value = true;
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
    try {
      scrollToTop(HomeController.scrollController1);
      scrollToTop(HomeController.scrollController2);
      scrollToTop(HomeController.scrollController3);
      scrollToTop(HomeController.scrollController4);
      scrollToTop(HomeController.scrollController5);
      scrollToTop(HomeController.scrollController6);
    } catch (e) {}
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
            date: downloadMusic.date,
            category: downloadMusic.category,
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
          var artist = await artistDao.findArtistByArtistBin(artistModel.v);

          if (artist == null) {
            artist = Artist(
                uid: artistModel.v,
                name: artistModel.k,
                photo: "${Const.ossUrl}LLMP/artist/${artistModel.v}.jpg",
                music: [mMusic.musicId!],
                group: mMusic.group!);
            await artistDao.insertArtist(artist);
          } else {
            artist.music.add(mMusic.musicId!);
            await artistDao.updateArtist(artist);
          }
        }
      }
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  Future<void> downloadArtistModelList() async {
    final result = await Network.dio?.request<String>(Const.artistModelUrl);
    if (result != null && result.data != null) {
      artistList.addAll(artistFromJson(result.data!));
    }
  }

  /****************  Album  ****************/

  /// 根据albumUId获取专辑
  Future<Album?> findAlbumById(String uid) async {
    return await albumDao.findAlbumByUId(uid);
  }

  Future<void> clearAllMusic() async {
    try {
      await albumDao.deleteAllAlbums();
      await musicDao.deleteAllMusics();
      await artistDao.deleteAllArtists();
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  /// 清空全部专辑
  Future<void> clearAllAlbum() async {
    try {
      await albumDao.deleteAllAlbums();
      await musicDao.deleteAllMusics();
      await lyricDao.deleteAllLyrics();
      await artistDao.deleteAllArtists();
      await menuDao.deleteAllMenus();
      await playListMusicDao.deleteAllPlayListMusics();
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  /// 通过albumId获取专辑下的全部歌曲
  Future<List<Music>> findAllMusicsByAlbumId(String albumId) async {
    return await musicDao.findAllMusicsByAlbumId(albumId);
  }

  /// 通过musicUId获取歌曲
  Future<Music?> findMusicById(String uid) async {
    return await musicDao.findMusicByUId(uid);
  }

  /// 更新歌曲最后一次的播放时间
  Future<void> refreshMusicTimestamp(String musicId) async {
    final music = await musicDao.findMusicByUId(musicId);
    if (music == null) {
      return;
    }
    music.timestamp = DateTime.now().millisecondsSinceEpoch;
    await musicDao.updateMusic(music);
    GlobalLogic.to.recentList.value = await musicDao.findRecentMusics();
    return;
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
      Log4f.e(msg: e.toString(), writeFile: true);
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
      Log4f.e(msg: e.toString(), writeFile: true);
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
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  /// 删除歌单中的歌曲
  // @param 歌单id
  // @param 要删除的歌曲id列表
  // @return 1: 刷新界面 ;2: 需要返回上一页
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
      Log4f.e(msg: e.toString(), writeFile: true);
    }
    return -1;
  }

  /// 删除歌单
  Future<void> deleteMenuById(int menuId) async {
    try {
      await menuDao.deleteMenuById(menuId);
      await findAllMenuList();
    } catch (e) {
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  /****************  PlayList  ****************/

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

  /****************  Love  ****************/

  /// 获取我喜欢列表
  findAllLoveListByGroup(String group) {
    try {
      final loveList = <Music>[];
      GlobalLogic.to.musicList.where((music) {
        if (group == Const.groupAll) {
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

  /// 更新歌曲列表中全部的喜欢状态
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

  /****************  Artist  ****************/

  Future<List<Music>> findAllMusicsByArtistBin(String artistBin) async {
    final artist = await artistDao.findArtistByArtistBin(artistBin);
    if (artist == null) {
      return [];
    }
    return await musicDao.findMusicsByMusicIds(artist.music);
  }

  scrollToTop(ScrollController scrollController) {
    try {
      scrollController.jumpTo(0);
    } catch (e) {}
  }

  /****************  Transfer  ****************/

  Future<TransData> getTransPhoneData({bool needMenuList = false}) async {
    final loveList = <String>[];
    final menuList = <TransMenu>[];
    GlobalLogic.to.musicList.where((music) => music.isLove).forEach((music) {
      loveList.add(music.musicId!);
    });
    if (needMenuList) {
      for (var menu in GlobalLogic.to.menuList) {
        if (menu.id > 100) {
          menuList.add(TransMenu(
              menuId: menu.id,
              musicList: menu.music,
              name: menu.name,
              date: menu.date));
        }
      }
    }
    return TransData(love: loveList, menu: menuList);
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
