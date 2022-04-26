import 'dart:async';
import 'dart:collection';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:common_utils/common_utils.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

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
  var playingMusic = Music().obs;

  var lrcType = 0.obs; // 0:原文; 1:翻译; 2:罗马音
  bool isCanMiniPlayerScroll = true;

  final List<StreamSubscription> _subscriptions = [];

  final mPlayList = <Music>[];

  static PlayerLogic get to => Get.find();

  @override
  void onInit() {
    mPlayer = AssetsAudioPlayer.withId("LLMP");
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
    _subscriptions.add(mPlayer.playlistAudioFinished.listen((data) {
      print('playlistAudioFinished: $data');
    }));
    _subscriptions.add(mPlayer.current.listen((data) {
      if (data == null) {
        return;
      }
      final String uid = data.audio.audio.metas.id!;
      final String? group = data.audio.audio.metas.extra?["group"];
      playingMusic.value = GlobalLogic.to.getMusicByUidAndGroup(uid, group);
      getLrc();
    }));

    eventBus.on<PlayingLrcEvent>().listen((lrc) {
      preJPLrc.value = lrc.playingLrc.preJPLrc ?? "";
      currentJPLrc.value = lrc.playingLrc.currentJPLrc ?? "";
      nextJPLrc.value = lrc.playingLrc.nextJPLrc ?? "";
    });
  }

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

  changePlayIndex(int index) {
    mPlayer.playlistPlayAtIndex(index);
  }

  togglePlay() {
    mPlayer.playOrPause();
    isPlaying.value = mPlayer.isPlaying.value;
  }

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