import 'dart:async';
import 'dart:collection';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:common_utils/common_utils.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/PlayMode.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';

import '../eventbus/eventbus.dart';
import '../eventbus/playing_lrc_bus.dart';
import '../models/Music.dart';

class PlayerLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  late AssetsAudioPlayer mPlayer;

  var preJPLrc = "".obs;
  var currentJPLrc = "".obs;
  var nextJPLrc = "".obs;
  var jpLrc = "".obs;
  var zhLrc = "".obs;
  var romaLrc = "".obs;
  var isPlaying = false.obs;
  var playingPosition = 0.obs;
  var playingTotal = 0.obs;
  var playingMusic = Music().obs;

  var lrcType = 0.obs; // 0:原文; 1:翻译; 2:罗马音
  bool isCanMiniPlayerScroll = true;
  PlayMode playMode = PlayMode.playlist;

  final List<StreamSubscription> _subscriptions = [];

  final mPlayList = <Music>[];

  static PlayerLogic get to => Get.find();

  @override
  void onInit() {
    /// 指定播放器 id, 防止播放多个实例
    mPlayer = AssetsAudioPlayer.withId("LLMP");
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
      switch(event) {
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

    /// 播放列表播放结束监听
    _subscriptions.add(mPlayer.playlistAudioFinished.listen((data) {
      print('playlistAudioFinished: $data');
    }));

    _subscriptions.add(mPlayer.currentPosition.listen((duration) {
      playingPosition.value = duration.inMilliseconds;
    }));

    /// 当前播放监听
    _subscriptions.add(mPlayer.current.listen((data) {
      if (data == null) {
        return;
      }
      playingTotal.value = data.audio.duration.inMilliseconds;
      final String uid = data.audio.audio.metas.id!;
      final String? group = data.audio.audio.metas.extra?["group"];
      final music = GlobalLogic.to.getMusicByUidAndGroup(uid, group);
      for (final music in mPlayList) {
        music.isPlaying = music.uid == uid;
      }
      music.isPlaying = true;
      playingMusic.value = music;
      getLrc();
    }));

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
        tempList.add(Audio.file(SDUtils.path + musicPath!, metas: Metas(
            id: music.uid,
            title: music.name,
            artist: music.artist,
            album: music.albumName,
            extra: map,
            image: (coverPath == null || coverPath.isEmpty) ? null : MetasImage(
                path: SDUtils.path + coverPath, type: ImageType.file),
            onImageLoadFail: const MetasImage(
                path: "assets/thumb/XVztg3oXmX4.jpg", type: ImageType.asset)
        )));
      }
    }
    mPlayer.open(
      Playlist(audios: tempList),
      autoStart: true,
      showNotification: true,
    );
    mPlayList.clear();
    mPlayList.addAll(musicList);
  }

  /// 播放 播放列表 指定位置的歌曲
  changePlayIndex(int index) {
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
    changePlayIndex(currentMusic.index + direction);
  }

  /// 开关播放
  togglePlay() {
    mPlayer.playOrPause();
    isPlaying.value = mPlayer.isPlaying.value;
  }

  /// 获取中/日/罗马歌词
  getLrc() async {
    final jp = playingMusic.value.jpUrl;
    final zh = playingMusic.value.zhUrl;
    final roma = playingMusic.value.romaUrl;
    if (jp == null || jp.isEmpty) {
      jpLrc.value = "";
    } else {
      jpLrc.value = await Network.getSync(jp);
    }
    if (zh == null || zh.isEmpty) {
      zhLrc.value = "";
    } else {
      zhLrc.value = await Network.getSync(zh);
    }
    if (roma == null || roma.isEmpty) {
      romaLrc.value = "";
    } else {
      romaLrc.value = await Network.getSync(roma);
    }
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

  toggleLove() {

  }

  seekTo(int ms) {
    mPlayer.seek(Duration(milliseconds: ms), force: true);
  }

  _setPlayMode(PlayMode? mode) {
    switch (mode) {
      case PlayMode.playlist:
        playMode = PlayMode.playlist;
        mPlayer.setLoopMode(LoopMode.playlist);
        mPlayer.shuffle = false;
        break;
      case PlayMode.single:
        playMode = PlayMode.single;
        mPlayer.setLoopMode(LoopMode.single);
        mPlayer.shuffle = false;
        break;
      default:
        playMode = PlayMode.shuffling;
        mPlayer.setLoopMode(LoopMode.playlist);
        mPlayer.shuffle = true;
        break;
    }
    SpUtil.put("playMode", mode?.index ?? 0);
  }

  /// 切换循环播放模式
  changePlayMode() {
    switch (playMode) {
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