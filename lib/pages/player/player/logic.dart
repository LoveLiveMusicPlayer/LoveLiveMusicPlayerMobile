import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/position_data.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/pages/player/player/player_type_enum.dart';
import 'package:lovelivemusicplayer/utils/http_server.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;

class PlayerPageLogic extends GetxController {
  StreamSubscription? loginSubscription;

  // 是否是封面
  var showContent = PlayerType.cover.obs;

  // 是否被隐藏
  var isOpen = false.obs;

  Stream<PositionData> get positionDataStream =>
      rx_dart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          PlayerLogic.to.mPlayer.positionStream,
          PlayerLogic.to.mPlayer.bufferedPositionStream,
          PlayerLogic.to.mPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void onInit() {
    super.onInit();
    loginSubscription = eventBus.on<PlayerClosableEvent>().listen((event) {
      /// 点击关闭按钮后确定关闭掉全量歌词界面，防止cpu消耗过多
      if (showContent.value != PlayerType.cover && event.isOpen) {
        setStatus(cover: true, open: event.isOpen);
      } else {
        setStatus(open: event.isOpen);
      }
    });
  }

  setStatus({bool? cover, bool? open}) {
    MyHttpServer.stopServer();
    if (cover != null && cover != (showContent.value == PlayerType.cover)) {
      showContent.value = cover ? PlayerType.cover : PlayerType.lyric;
    }
    if (open != null && open != isOpen.value) {
      isOpen.value = open;
    }
  }

  onCoverTap() {
    setStatus(cover: false);
  }

  onLyricTap() {
    setStatus(cover: true);
  }

  onMoreTap() {
    if (PlayerLogic.to.playingMusic.value.musicId == null) {
      return;
    }
    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        builder: (context) {
          return DialogMoreWithMusic(
              music: Music.deepClone(PlayerLogic.to.playingMusic.value),
              isPlayer: true,
              onClosePanel: () {
                GlobalLogic.closePanel();
                // GlobalLogic.mobileWeSlideFooterController.hide();
              },
              changeLoveStatusCallback: (status) {
                PlayerLogic.to.playingMusic.value =
                    Music.deepClone(PlayerLogic.to.playingMusic.value);
              });
        });
  }

  onTachiTap() {
    if (showContent.value == PlayerType.lyric) {
      MyHttpServer.startServer();
      showContent.value = PlayerType.tachie;
    } else {
      showContent.value = PlayerType.lyric;
    }
  }

  onAddSong() {
    if (PlayerLogic.to.playingMusic.value.musicId == null) {
      return;
    }
    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        builder: (context) {
          return DialogAddSongSheet(
            musicList: [Music.deepClone(PlayerLogic.to.playingMusic.value)],
            changeLoveStatusCallback: (status) async {
              PlayerLogic.to.playingMusic.value =
                  Music.deepClone(PlayerLogic.to.playingMusic.value);
            },
          );
        });
  }

  @override
  void onClose() {
    loginSubscription?.cancel();
    MyHttpServer.stopServer();
    super.onClose();
  }
}
