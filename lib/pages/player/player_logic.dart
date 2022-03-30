import 'dart:async';
import 'package:common_utils/common_utils.dart';
import 'package:event_bus/event_bus.dart';
import 'package:get/get.dart';
import '../../models/Music.dart';
import 'player_state.dart' as player;
import 'package:assets_audio_player/assets_audio_player.dart';

class PlayerLogic extends GetxController {
  final player.PlayerState state = player.PlayerState();

  final mPlayer = AssetsAudioPlayer();
  final List<StreamSubscription> _subscriptions = [];

  final mPlayList = <Audio>[];

  @override
  void onInit() {
    super.onInit();
    _subscriptions.add(mPlayer.current.listen((data) {
      LogUtil.e(data);
    }));
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
}