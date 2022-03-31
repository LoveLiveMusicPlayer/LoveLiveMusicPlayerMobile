import 'dart:async';
import 'package:common_utils/common_utils.dart';
import 'package:get/get.dart';
import '../eventbus/playing_lrc_bus.dart';
import '../models/Music.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import '../eventbus/eventbus.dart';

class PlayerLogic extends SuperController with GetSingleTickerProviderStateMixin {
  var preJPLrc = "".obs;
  var currentJPLrc = "".obs;
  var nextJPLrc = "".obs;

  final mPlayer = AssetsAudioPlayer();
  final List<StreamSubscription> _subscriptions = [];

  final mPlayList = <Audio>[];

  @override
  void onInit() {
    _subscriptions.add(mPlayer.current.listen((data) {
      LogUtil.e(data);
    }));

    eventBus.on<PlayingLrcEvent>().listen((lrc) {
      preJPLrc.value = lrc.playingLrc.preJPLrc ?? "";
      currentJPLrc.value = lrc.playingLrc.currentJPLrc ?? "";
      nextJPLrc.value = lrc.playingLrc.nextJPLrc ?? "";
    });
    super.onInit();
  }

  playMusic(List<Music> musicList, {int index = 0}) {
    if (musicList.isEmpty) {
      return;
    }
    final tempList = <Audio>[];
    
    musicList.forEach((element) {
      final musicPath = element.musicPath;
      final coverPath = element.coverPath;
      if (musicPath != null && musicPath.isNotEmpty) {
        tempList.add(Audio(musicPath, metas: Metas(
          title: element.name,
          artist: element.artist,
          album: element.albumName,
          image: (coverPath == null || coverPath.isEmpty) ? null : MetasImage(path: coverPath, type: ImageType.file),
          onImageLoadFail: const MetasImage(path: "assets/thumb/XVztg3oXmX4.jpg", type: ImageType.asset),
        )));
      }
    });
    mPlayList.clear();
    mPlayList.addAll(tempList);
    mPlayer.open(
      Playlist(audios: mPlayList),
      autoStart: false,
      showNotification: true,
    );
  }
  
  changePlayIndex(int index) {
    mPlayer.playlistPlayAtIndex(index);
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