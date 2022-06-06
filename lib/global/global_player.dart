import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter_lyric/lyric_parser/parser_smart.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/Lyric.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';

import '../models/Music.dart';

class PlayerLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  final mPlayer = AudioPlayer();

  static const loopModes = [
    LoopMode.off,
    LoopMode.all,
    LoopMode.one,
  ];

  var preJPLrc = "".obs;
  var currentJPLrc = "".obs;
  var nextJPLrc = "".obs;
  var jpLrc = "".obs;
  var zhLrc = "".obs;
  var romaLrc = "".obs;
  var isPlaying = false.obs;
  var playingPosition = const Duration(milliseconds: 0).obs;
  var playingMusic = Music().obs;

  var lrcType = 0.obs; // 0:原文; 1:翻译; 2:罗马音
  var isCanMiniPlayerScroll = true.obs;

  var mPlayList = <Music>[];

  static PlayerLogic get to => Get.find();

  @override
  void onInit() {
    SpUtil.getInt("loopMode", 0).then((index) => changeLoopMode(index));

    /// 播放状态监听
    mPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    mPlayer.positionStream.listen((duration) {
      playingPosition.value = duration;
      final lrcList = ParserSmart(jpLrc.value).parseLines();
      for (var i = 0; i < lrcList.length; i++) {
        if (i == lrcList.length - 1 && (lrcList[i].startTime ?? 0) < duration.inMilliseconds) {
          nextJPLrc.value = "";
          currentJPLrc.value =
          (i <= lrcList.length - 1) ? lrcList[i].mainText ?? "" : "";
          preJPLrc.value = (i - 1 <= lrcList.length - 1 && i > 0)
              ? lrcList[i - 1].mainText ?? ""
              : "";
          break;
        } else if ((lrcList[i].startTime ?? 0) < duration.inMilliseconds &&
            (lrcList[i + 1].startTime ?? 0) > duration.inMilliseconds){
          nextJPLrc.value = (i + 1 <= lrcList.length - 1)
              ? lrcList[i + 1].mainText ?? ""
              : "";
          currentJPLrc.value =
          (i <= lrcList.length - 1) ? lrcList[i].mainText ?? "" : "";
          preJPLrc.value = (i - 1 <= lrcList.length - 1 && i > 0)
              ? lrcList[i - 1].mainText ?? ""
              : "";
          break;
        }
      }
    });

    /// 当前播放监听
    mPlayer.currentIndexStream.listen((index) {
      if (index != null && mPlayList.isNotEmpty) {
        final currentMusic = mPlayList[index];
        for (var music in mPlayList) {
          music.isPlaying = music.uid == currentMusic.uid;
        }
        if (isCanMiniPlayerScroll.value) {
          print("aaa: 111");
          playingMusic.value = currentMusic;
          getLrc(false);
        }
      }
    });
  }

  /// 播放指定列表的歌曲
  playMusic(List<Music> musicList, {int index = 0, ScrollCallback? callback}) {
    if (musicList.isEmpty) {
      return;
    }

    final audioList = <AudioSource>[];
    for (var i = 0; i < musicList.length; i++) {
      final music = musicList[i];
      final coverPath = music.coverPath;
      final musicPath = music.musicPath;
      if (musicPath?.isNotEmpty == true) {
        audioList.add(AudioSource.uri(
          Uri.file('${SDUtils.path}$musicPath'),
          tag: MediaItem(
            id: music.uid!,
            title: music.name!,
            album: music.albumName!,
            artist: music.artist,
            duration: playingPosition.value,
            artUri: (coverPath == null || coverPath.isEmpty)
                ? Uri.parse(Const.logo)
                : Uri.file(SDUtils.path + coverPath),
          ),
        ));
      }
    }
    mPlayer.setAudioSource(ConcatenatingAudioSource(children: audioList),
        initialIndex: index);
    mPlayList = musicList;
    mPlayer.play();
    if (callback == null) {
      print("aaa: 222");
      playingMusic.value = musicList[index];
    } else {
      callback(musicList[index]);
    }
    getLrc(false);
  }

  /// 播放 播放列表 指定位置的歌曲
  changePlayIndex(bool isController, int index) async {
    if (isController) {
      isCanMiniPlayerScroll.value = true;
      return;
    }
    playMusic(mPlayList, index: index, callback: (Music music) async {
      await Future.delayed(const Duration(milliseconds: 300));
      isCanMiniPlayerScroll.value = true;
      print("aaa: 333");
      playingMusic.value = music;
      getLrc(false);
    });
  }

  /// 开关播放
  togglePlay() {
    if (isPlaying.value) {
      mPlayer.pause();
    } else {
      mPlayer.play();
    }
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
    mPlayer.seek(Duration(milliseconds: ms));
  }

  /// 切换循环模式
  void changeLoopMode(int index) async {
    final nextIndex = index % loopModes.length;

    /// 特殊处理随机播放：当处于LoopMode.off模式时，更改为循环列表且随机洗牌
    mPlayer.setLoopMode(loopModes[nextIndex] == LoopMode.off
        ? LoopMode.all
        : loopModes[nextIndex]);
    final enableShuffle = nextIndex == 0;
    if (enableShuffle) {
      await mPlayer.shuffle();
    }
    await mPlayer.setShuffleModeEnabled(enableShuffle);
    SpUtil.put("loopMode", index);
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

typedef ScrollCallback = void Function(Music music);
