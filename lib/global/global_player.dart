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

  // 播放列表<AudioSource>
  final audioSourceList = ConcatenatingAudioSource(children: []);
  // 播放列表<Music>
  var mPlayList = <Music>[];

  // 前一句歌词
  var preJPLrc = "".obs;
  // 当前句歌词
  var currentJPLrc = "".obs;
  // 后一句歌词
  var nextJPLrc = "".obs;

  // 日文全量歌词
  var jpLrc = "".obs;
  // 中文全量歌词
  var zhLrc = "".obs;
  // 罗马音全量歌词
  var romaLrc = "".obs;

  // 播放状态
  var isPlaying = false.obs;
  // 播放位置
  var playingPosition = const Duration(milliseconds: 0).obs;
  // 当前播放位置索引
  var playingMusicIndex = 0.obs;
  // 当前播放歌曲
  var playingMusic = Music().obs;

  // 切换显示歌词类型 (0:原文; 1:翻译; 2:罗马音)
  var lrcType = 0.obs;

  static PlayerLogic get to => Get.find();

  @override
  void onInit() {
    SpUtil.getInt("loopMode", 0).then((index) => changeLoopMode(index));

    /// 播放状态监听
    mPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    /// 播放位置监听
    mPlayer.positionStream.listen((duration) {
      playingPosition.value = duration;
      // 修改前一句、当前、后一句歌词内容
      final lrcList = ParserSmart(jpLrc.value).parseLines();
      for (var i = 0; i < lrcList.length; i++) {
        if (i == lrcList.length - 1 &&
            (lrcList[i].startTime ?? 0) < duration.inMilliseconds) {
          nextJPLrc.value = "";
          currentJPLrc.value =
              (i <= lrcList.length - 1) ? lrcList[i].mainText ?? "" : "";
          preJPLrc.value = (i - 1 <= lrcList.length - 1 && i > 0)
              ? lrcList[i - 1].mainText ?? ""
              : "";
          break;
        } else if ((lrcList[i].startTime ?? 0) < duration.inMilliseconds &&
            (lrcList[i + 1].startTime ?? 0) > duration.inMilliseconds) {
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
        // 修改播放位置索引
        playingMusicIndex.value = index;
        // 修改当前播放歌曲
        final currentMusic = mPlayList[index];
        for (var music in mPlayList) {
          music.isPlaying = music.uid == currentMusic.uid;
        }
        if (playingMusic.value != currentMusic) {
          playingMusic.value = currentMusic;
        }
        getLrc(false);
      }
    });
  }

  /// 播放指定列表的歌曲
  playMusic(List<Music> musicList, {int index = 0}) {
    if (musicList.isEmpty) {
      return;
    }

    // 设置新的播放列表
    final audioList = <AudioSource>[];
    // 传入列表是否和原播放列表相同
    bool isSameList = true;

    for (var i = 0; i < musicList.length; i++) {
      final coverPath = musicList[i].coverPath;
      final musicPath = musicList[i].musicPath;
      if (musicPath?.isNotEmpty == true) {
        audioList.add(genAudioSourceUri(musicPath, musicList[i], coverPath));
      }
      if (isSameList == true && (mPlayList.isEmpty || musicList[i] != mPlayList[i])) {
        isSameList = false;
      }
    }

    audioSourceList.clear();
    audioSourceList.addAll(audioList);
    mPlayer.setAudioSource(audioSourceList, initialIndex: index);

    // 如果不相同，替换播放列表
    if (!isSameList) {
      mPlayList = [...musicList];
    }

    // 当前是否正在播放
    if (isPlaying.value) {
      if (isSameList) {
        // 如果正在播放且列表相同，直接跳到对应索引播放
        mPlayer.seek(Duration.zero, index: index);
      } else {
        // 如果正在播放但是列表不同，就停止再打开播放器
        mPlayer.stop();
        mPlayer.play();
      }
    } else {
      // 首次播放
      mPlayer.play();
    }
    if (playingMusic.value != musicList[index]) {
      playingMusic.value = musicList[index];
    }
    getLrc(false);
  }

  /// 插入到下一曲
  addNextMusic(Music music) {
    final coverPath = music.coverPath;
    final musicPath = music.musicPath;
    if (musicPath?.isNotEmpty == true) {
      if (music.uid == playingMusic.value.uid) {
        // 如果选中的歌曲是当前播放的歌曲
        return;
      }
      // 搜索并删除当前要插入的歌曲
      for (var index = 0; index < mPlayList.length; index++) {
        if (mPlayList[index].uid == music.uid) {
          audioSourceList.removeAt(index);
          mPlayList.removeAt(index);
          break;
        }
      }
      // 将插入的歌曲放在当前播放歌曲的后面
      for (var index = 0; index < mPlayList.length; index++) {
        if (mPlayList[index].uid == playingMusic.value.uid) {
          audioSourceList.insert(
              index + 1, genAudioSourceUri(musicPath, music, coverPath));
          mPlayList.insert(index + 1, music);
          break;
        }
      }
    }
  }

  /// 生成一个播放URI
  UriAudioSource genAudioSourceUri(
      String? musicPath, Music music, String? coverPath) {
    return AudioSource.uri(
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
    );
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

  /// 切换歌词类型
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

  /// 拖拽到指定位置播放
  seekTo(int ms) {
    mPlayer.seek(Duration(milliseconds: ms));
  }

  /// 切换循环模式
  void changeLoopMode(int index) async {
    // 先设置随机模式，再设置循环模式，否则监听到的流会遗漏随机状态
    final enableShuffle = index == 0;
    await mPlayer.setShuffleModeEnabled(enableShuffle);
    if (enableShuffle) {
      await mPlayer.shuffle();
    }
    // 特殊处理随机播放：当处于LoopMode.off模式时，更改为循环列表且随机洗牌
    mPlayer.setLoopMode(loopModes[index] == LoopMode.off
        ? LoopMode.all
        : loopModes[index]);
    await SpUtil.put("loopMode", index);
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
