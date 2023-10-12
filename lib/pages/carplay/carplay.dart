import 'dart:async';

import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/play_list_music.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_album.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_mine.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_music.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_util.dart';
import 'package:synchronized/synchronized.dart';

class Carplay {
  static Carplay? _singleton;
  static final Lock _lock = Lock();

  static var musicList = <CPListItem>[];
  static final List<CPListSection> sectionMusic = [];

  static Carplay init() {
    if (_singleton == null) {
      _lock.synchronized(() {
        if (_singleton == null) {
          var singleton = Carplay._();
          singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton!;
  }

  Carplay._();

  CPConnectionStatusTypes connectionStatus = CPConnectionStatusTypes.unknown;
  static final FlutterCarplay _flutterCarplay = FlutterCarplay();

  void _init() async {
    FlutterCarplay.setRootTemplate(
      rootTemplate: CPTabBarTemplate(
        templates: [
          CarplayMusic.getInstance().get(),
          CarplayAlbum.getInstance().get(),
          (await CarplayMine.getInstance()).get(),
        ],
      ),
      animated: true,
    );

    _flutterCarplay.forceUpdateRootTemplate();

    _flutterCarplay.addListenerOnConnectionChange(onCarplayConnectionChange);

    Future.delayed(const Duration(seconds: 1)).then((value) {
      isCanUseSmartDialog = true;
      changePlayingMusic(PlayerLogic.to.playingMusic.value);
    });
  }

  /// 播放列表转换为CP列表
  static Future<void> parse4PlayList(List<PlayListMusic> playList) async {
    if (CarplayUtil.isTouchFromCar) {
      CarplayUtil.isTouchFromCar = false;
      return;
    }
    musicList.clear();
    for (var playListMusic in playList) {
      musicList.add(CPListItem(
          elementId: CarplayUtil.genUniqueId(playListMusic.musicId),
          onPress: (complete, cp) {
            Carplay.handlePlayMusic(complete, cp, musicList);
          },
          isPlaying: playListMusic.isPlaying,
          text: playListMusic.musicName));
    }

    CarplayUtil.handleReCreatePage(musicList);
  }

  static void changePlayingMusic(Music music) {
    final imagePath = CarplayUtil.music2Image(music);
    sectionMusic.first.items.first
        .updateTextAndImage("当前播放: ${music.musicName ?? "暂无歌曲"}", imagePath);
  }

  void onCarplayConnectionChange(CPConnectionStatusTypes status) {
    connectionStatus = status;
  }

  /// 车机上主动触发
  /// @param cp        当前选择的item
  /// @param musicList 歌曲列表
  /// @param complete  执行完成回调
  static handlePlayMusic(
      Function() complete, CPListItem cp, List<CPListItem> cpList) async {
    CarplayUtil.isTouchFromCar = true;

    final musicList = await CarplayUtil.cpList2MusicList(cpList);

    for (var i = 0; i < musicList.length; i++) {
      if (musicList[i].musicId == cp.uniqueId) {
        cp.setIsPlaying(true);
        var completer = Completer<void>();
        await PlayerLogic.to
            .playMusic(musicList, mIndex: i)
            .then((_) => completer.complete());
        await completer.future;
        break;
      }
    }

    complete();
  }

  static void forceReload() {
    Log4f.d(msg: "forceReload");
    _flutterCarplay.forceUpdateRootTemplate();
  }

  void dispose() {
    _flutterCarplay.removeListenerOnConnectionChange();
  }
}
