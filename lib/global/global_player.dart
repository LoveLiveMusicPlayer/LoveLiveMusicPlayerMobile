import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:common_utils/common_utils.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Lyric.dart';
import 'package:lovelivemusicplayer/models/PlayMode.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';

import '../eventbus/eventbus.dart';
import '../eventbus/playing_lrc_bus.dart';
import '../models/Music.dart';

class PlayerLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  AssetsAudioPlayer mPlayer = AssetsAudioPlayer.withId("LLMP");

  var preJPLrc = "".obs;
  var currentJPLrc = "".obs;
  var nextJPLrc = "".obs;
  var jpLrc = "".obs;
  var zhLrc = "".obs;
  var romaLrc = "".obs;
  var isPlaying = false.obs;
  var playingPosition = const Duration(milliseconds: 0).obs;
  var playingTotal = const Duration(milliseconds: 0).obs;
  var playingMusic = Music().obs;

  var lrcType = 0.obs; // 0:原文; 1:翻译; 2:罗马音
  bool isCanMiniPlayerScroll = true;
  var playMode = PlayMode.playlist.obs;

  final List<StreamSubscription> _subscriptions = [];

  final mPlayList = <Music>[];

  static PlayerLogic get to => Get.find();

  @override
  void onInit() {
    /// 指定播放器 id, 防止播放多个实例
    SpUtil.getInt("playMode").then((mode) {
      if (PlayMode.playlist.index == mode) {
        print("播放模式：列表循环");
        _setPlayMode(PlayMode.playlist);
      } else if (PlayMode.single.index == mode) {
        _setPlayMode(PlayMode.single);
        print("播放模式：单曲循环");
      } else if (PlayMode.shuffling.index == mode) {
        _setPlayMode(PlayMode.shuffling);
        print("播放模式：随机播放");
      } else {
        _setPlayMode(null);
        print("播放模式：首次列表循环");
      }
    });

    /// 播放状态监听
    _subscriptions.add(mPlayer.playerState.listen((event) {
      switch (event) {
        case PlayerState.play:
          isPlaying.value = true;
          print("player is playing...");
          break;
        case PlayerState.pause:
          isPlaying.value = false;
          print("player is pause...");
          break;
        case PlayerState.stop:
          isPlaying.value = false;
          print("player is stop...");
          break;
      }
    }));

    /// 歌曲播放结束监听
    _subscriptions.add(mPlayer.playlistAudioFinished.listen((data) {
      print('playlistAudioFinished: $data');
    }));

    _subscriptions.add(mPlayer.currentPosition.listen((duration) {
      // LogUtil.e(DateUtil.formatDate(DateUtil.getDateTimeByMs(duration.inMilliseconds), format: "mm:ss"));
      playingPosition.value = duration;
    }));

    /// 当前播放监听
    _subscriptions.add(mPlayer.current.listen((data) {
      if (data == null) {
        return;
      }
      playingTotal.value = data.audio.duration;
      final String uid = data.audio.audio.metas.id!;
      final String? group = data.audio.audio.metas.extra?["group"];
      final music = GlobalLogic.to.getMusicByUidAndGroup(uid, group);
      for (final music in mPlayList) {
        music.isPlaying = music.uid == uid;
      }
      music.isPlaying = true;
      playingMusic.value = music;
      getLrc(false);
    }));

    mPlayer.loopMode.listen((loopMode){
      LogUtil.e("loopMode: $loopMode");
    });

    eventBus.on<PlayingLrcEvent>().listen((lrc) {
      preJPLrc.value = lrc.playingLrc.preJPLrc ?? "";
      currentJPLrc.value = lrc.playingLrc.currentJPLrc ?? "";
      nextJPLrc.value = lrc.playingLrc.nextJPLrc ?? "";
    });
  }

  /// 播放指定列表的歌曲
  playMusic(List<Music> musicList, {int index = 0}) {
    if (musicList.isEmpty) {
      return;
    }

    final tempList = <Audio>[];
    Map<String, dynamic> map = {};
    for (var i = 0; i < musicList.length; i++) {
      final music = musicList[i];
      final coverPath = music.coverPath;
      final musicPath = music.musicPath;
      if (musicPath?.isNotEmpty == true) {
        map["group"] = music.group;
        tempList.add(Audio.file(SDUtils.path + musicPath!,
            metas: Metas(
                id: music.uid,
                title: music.name,
                artist: music.artist,
                album: music.albumName,
                extra: map,
                image: (coverPath == null || coverPath.isEmpty)
                    ? null
                    : MetasImage(
                        path: SDUtils.path + coverPath, type: ImageType.file),
                onImageLoadFail: const MetasImage(
                    path: Const.logo,
                    type: ImageType.asset))));
      }
    }
    var mode = LoopMode.none;
    switch (playMode.value) {
      case PlayMode.playlist:
        mode = LoopMode.playlist;
        break;
      case PlayMode.single:
        mode = LoopMode.single;
        break;
      default:
        break;
    }
    mPlayer.open(
      Playlist(audios: tempList),
      autoStart: true,
      showNotification: true,
      loopMode: mode
    );
    mPlayList.clear();
    mPlayList.addAll(musicList);
  }

  /// 播放 播放列表 指定位置的歌曲
  changePlayIndex(bool isController, int index) {
    if (isController && mPlayer.isFirstBackgroundToForeground) {
      return;
    }
    isCanMiniPlayerScroll = false;
    mPlayer.playlistPlayAtIndex(index);
    isCanMiniPlayerScroll = true;
  }

  /// 上一曲 / 下一曲
  changePlayPrevOrNext(int direction) {
    final currentMusic = mPlayer.current.value;
    if (currentMusic == null) {
      return;
    }
    changePlayIndex(false, currentMusic.index + direction);
  }

  /// 开关播放
  togglePlay() {
    mPlayer.playOrPause();
    isPlaying.value = mPlayer.isPlaying.value;
  }

  /// 获取中/日/罗马歌词
  getLrc(bool forceRefresh) async {
    jpLrc.value = "";
    zhLrc.value = "";
    romaLrc.value = "";

    final uid = playingMusic.value.uid;
    final jp =
        await handleLRC("jp", playingMusic.value.jpUrl, uid, forceRefresh);
    if (jp != null) {
      jpLrc.value = jp;
    }
    final zh =
        await handleLRC("zh", playingMusic.value.zhUrl, uid, forceRefresh);
    if (zh != null) {
      zhLrc.value = zh;
    }
    final roma =
        await handleLRC("roma", playingMusic.value.romaUrl, uid, forceRefresh);
    if (roma != null) {
      romaLrc.value = roma;
    }
  }

  /// 处理歌词二级缓存
  /// @param type 要处理的歌词类型
  /// @param lrcUrl 歌词的网络地址
  /// @param uid 歌曲的id
  /// @param forceRefresh 是否强制刷新歌词
  Future<String?> handleLRC(
      String type, String? lrcUrl, String? uid, bool forceRefresh) async {
    if (lrcUrl != null && lrcUrl.isNotEmpty) {
      if (uid != null && uid.isNotEmpty) {
        /// null: 从未插入; "": 插入但没有值
        var lyric = await DBLogic.to.lyricDao.findLyricById(uid);
        String? storageLrc;
        if (lyric != null) {
          switch (type) {
            case "jp":
              storageLrc = lyric.jp ?? "";
              break;
            case "zh":
              storageLrc = lyric.zh ?? "";
              break;
            case "roma":
              storageLrc = lyric.roma ?? "";
              break;
          }
        }
        if (storageLrc == null || storageLrc.isEmpty || forceRefresh) {
          final netLrc = await Network.getSync(lrcUrl) ?? "";
          if (netLrc != null && netLrc.isNotEmpty) {
            if (storageLrc == null) {
              lyric = Lyric(uid: uid, jp: null, zh: null, roma: null);
            }
            if (lyric != null) {
              switch (type) {
                case "jp":
                  lyric.jp = netLrc;
                  break;
                case "zh":
                  lyric.zh = netLrc;
                  break;
                case "roma":
                  lyric.roma = netLrc;
                  break;
              }

              if (storageLrc == null) {
                await DBLogic.to.lyricDao.insertLyric(lyric);
              } else {
                await DBLogic.to.lyricDao.updateLrc(lyric);
              }
            }
            return netLrc;
          }
        } else {
          return storageLrc;
        }
      }
    }
    return null;
  }

  toggleTranslate() {
    switch (lrcType.value) {
      case 0:
        lrcType.value = 1;
        break;
      case 1:
        lrcType.value = 2;
        break;
      case 2:
        lrcType.value = 0;
        break;
    }
  }

  toggleLove() {}

  seekTo(int ms) {
    mPlayer.seek(Duration(milliseconds: ms), force: true);
  }

  _setPlayMode(PlayMode? mode) {
    switch (mode) {
      case PlayMode.playlist:
        playMode.value = PlayMode.playlist;
        mPlayer.shuffle = false;
        mPlayer.setLoopMode(LoopMode.playlist);
        LogUtil.e("顺序播放");
        break;
      case PlayMode.single:
        playMode.value = PlayMode.single;
        mPlayer.shuffle = false;
        mPlayer.setLoopMode(LoopMode.single);
        LogUtil.e("单曲循环");
        break;
      default:
        playMode.value = PlayMode.shuffling;
        mPlayer.shuffle = true;
        mPlayer.setLoopMode(LoopMode.playlist);
        LogUtil.e("随机播放");
        break;
    }
    SpUtil.put("playMode", mode?.index ?? 0);
  }

  /// 切换循环播放模式
  changePlayMode() {
    switch (playMode.value) {
      case PlayMode.playlist:
        _setPlayMode(PlayMode.single);
        break;
      case PlayMode.single:
        _setPlayMode(PlayMode.shuffling);
        break;
      default:
        _setPlayMode(PlayMode.playlist);
        break;
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
