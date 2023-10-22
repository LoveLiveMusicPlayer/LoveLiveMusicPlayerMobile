import 'dart:async';

import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/music.dart';
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

  static void changePlayingMusic(Music music) {
    final imagePath = CarplayUtil.music2Image(music);
    sectionMusic.first.items.first
        .updateTextAndImage("${'now_playing'.tr}${music.musicName ?? 'no_songs'.tr}", imagePath);
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

  void dispose() {
    _flutterCarplay.removeListenerOnConnectionChange();
  }
}
