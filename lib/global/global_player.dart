import 'dart:async';

import 'package:flutter_lyric/lyric_parser/parser_smart.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Lyric.dart';
import 'package:lovelivemusicplayer/models/PlayListMusic.dart';
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

  // 播放列表
  var mPlayList = <PlayListMusic>[];

  // 当前播放的歌词
  var playingJPLrc = {"pre": "", "current": "", "next": ""}.obs;

  // 全量歌词
  var fullLrc = {"jp": "", "zh": "", "roma": ""}.obs;

  // 播放状态
  var isPlaying = false.obs;

  // 播放位置
  var playingPosition = const Duration(milliseconds: 0).obs;

  // 当前播放歌曲
  var playingMusic = Music().obs;

  // 切换显示歌词类型 (0:原文; 1:翻译; 2:罗马音)
  var lrcType = 0.obs;

  // 是否使用封面皮肤
  var hasSkin = false.obs;

  static PlayerLogic get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    SpUtil.getInt(Const.spLoopMode, 0).then((index) => changeLoopMode(index));
    SpUtil.getBoolean(Const.spColorful, false)
        .then((skin) => hasSkin.value = skin);

    /// 播放状态监听
    mPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    /// 播放位置监听
    mPlayer.positionStream.listen((duration) {
      playingPosition.value = duration;
      changePlayingLyric(duration);
    });

    /// 当前播放监听
    mPlayer.currentIndexStream.listen((index) async {
      if (index != null &&
          mPlayList.isNotEmpty &&
          !GlobalLogic.to.isHandlePlay) {
        print("currentIndexStream: $index - ${mPlayList[index].musicName}");
        final currentMusic = mPlayList[index];
        await changePlayingMusic(currentMusic);
        persistencePLayList2(mPlayList, index).then((value) {
          GlobalLogic.to.isHandlePlay = false;
        });
        getLrc(false);
      }
    });
  }

  /// 持久化播放列表
  Future<void> persistencePlayList(List<Music> musicList, int index) async {
    mPlayList.clear();
    for (var i = 0; i < musicList.length; i++) {
      final music = musicList[i];
      mPlayList.add(PlayListMusic(
          musicId: music.musicId!,
          musicName: music.musicName!,
          artist: music.artist!,
          isPlaying: index == i));
    }
    for (var playListMusic in mPlayList) {
      playListMusic.isPlaying =
          playListMusic.musicId == musicList[index].musicId;
    }
    await DBLogic.to.updatePlayingList(mPlayList);
  }

  /// 持久化播放列表2
  Future<void> persistencePLayList2(
      List<PlayListMusic> playList, int index) async {
    for (var i = 0; i < playList.length; i++) {
      playList[i].isPlaying = index == i;
    }
    await DBLogic.to.updatePlayingList(playList);
  }

  /// 修改当前播放的歌曲
  Future<void> changePlayingMusic(PlayListMusic currentMusic) async {
    if (playingMusic.value.musicId != currentMusic.musicId) {
      final music = await DBLogic.to.findMusicByMusicId(currentMusic.musicId);
      if (music != null) {
        playingMusic.value = music;
      }
    }
  }

  /// 修改前一句、当前、后一句歌词内容
  Future<void> changePlayingLyric(Duration duration) async {
    final lrcList = ParserSmart(fullLrc["jp"]!).parseLines();
    for (var i = 0; i < lrcList.length; i++) {
      if (i == lrcList.length - 1 &&
          (lrcList[i].startTime ?? 0) < duration.inMilliseconds) {
        playingJPLrc.value = {
          "pre": (i - 1 <= lrcList.length - 1 && i > 0)
              ? lrcList[i - 1].mainText ?? ""
              : "",
          "current": (i <= lrcList.length - 1) ? lrcList[i].mainText ?? "" : "",
          "next": ""
        };
        break;
      } else if ((lrcList[i].startTime ?? 0) < duration.inMilliseconds &&
          (lrcList[i + 1].startTime ?? 0) > duration.inMilliseconds) {
        playingJPLrc.value = {
          "pre": (i - 1 <= lrcList.length - 1 && i > 0)
              ? lrcList[i - 1].mainText ?? ""
              : "",
          "current": (i <= lrcList.length - 1) ? lrcList[i].mainText ?? "" : "",
          "next":
              (i + 1 <= lrcList.length - 1) ? lrcList[i + 1].mainText ?? "" : ""
        };
        break;
      }
    }
  }

  /// 播放指定列表的歌曲
  playMusic(List<Music> musicList, {int index = 0, bool needPlay = true}) {
    // 如果上一次处理没有结束，直接跳过
    if (GlobalLogic.to.isHandlePlay) {
      return;
    }
    GlobalLogic.to.isHandlePlay = true;
    if (musicList.isEmpty) {
      GlobalLogic.to.isHandlePlay = false;
      return;
    }

    // 设置新的播放列表
    final audioList = <AudioSource>[];
    for (var music in musicList) {
      audioList.add(genAudioSourceUri(music));
    }
    mPlayer.stop();
    audioSourceList.clear();
    audioSourceList.addAll(audioList);
    audioList.clear();

    mPlayer.setAudioSource(audioSourceList, initialIndex: index).then((value) {
      if (needPlay) {
        mPlayer.play();
      }
      persistencePlayList(musicList, index).then((value) {
        if (playingMusic.value != musicList[index]) {
          playingMusic.value = musicList[index];
        }
        getLrc(false).then((value) {
          GlobalLogic.to.isHandlePlay = false;
        });
      });
    });
  }

  /// 插入到下一曲
  /// @param isNext true: 插入下一首; false: 插入末尾
  addNextMusic(Music music, {bool isNext = true}) {
    if (music.musicId == playingMusic.value.musicId) {
      // 如果选中的歌曲是当前播放的歌曲
      return;
    }
    // 搜索并删除当前要插入的歌曲
    for (var index = 0; index < mPlayList.length; index++) {
      if (mPlayList[index].musicId == music.musicId) {
        audioSourceList.removeAt(index);
        mPlayList.removeAt(index);
        break;
      }
    }
    final pMusic = PlayListMusic(
        musicId: music.musicId!,
        musicName: music.musicName!,
        artist: music.artist!);
    if (isNext) {
      // 将插入的歌曲放在当前播放歌曲的后面
      for (var index = 0; index < mPlayList.length; index++) {
        if (mPlayList[index].musicId == playingMusic.value.musicId) {
          audioSourceList.insert(index + 1, genAudioSourceUri(music));
          mPlayList.insert(index + 1, pMusic);
          break;
        }
      }
    } else {
      audioSourceList.insert(mPlayList.length, genAudioSourceUri(music));
      mPlayList.insert(mPlayList.length, pMusic);
    }
  }

  /// 生成一个播放URI
  UriAudioSource genAudioSourceUri(Music music) {
    return AudioSource.uri(
      Uri.file('${SDUtils.path}${music.musicPath}'),
      tag: MediaItem(
        id: music.musicId!,
        title: music.musicName!,
        album: music.albumName!,
        artist: music.artist,
        artUri: (music.coverPath == null || music.coverPath!.isEmpty)
            ? Uri.parse(Const.logo)
            : Uri.file(SDUtils.path + music.coverPath!),
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
  Future<void> getLrc(bool forceRefresh) async {
    var jpLrc = "";
    var zhLrc = "";
    var romaLrc = "";

    final uid = playingMusic.value.musicId;
    final jp =
        await handleLRC("jp", playingMusic.value.jpUrl, uid, forceRefresh);
    if (jp != null) {
      jpLrc = jp;
    }
    final zh =
        await handleLRC("zh", playingMusic.value.zhUrl, uid, forceRefresh);
    if (zh != null) {
      zhLrc = zh;
    }
    final roma =
        await handleLRC("roma", playingMusic.value.romaUrl, uid, forceRefresh);
    if (roma != null) {
      romaLrc = roma;
    }

    fullLrc.value = {"jp": jpLrc, "zh": zhLrc, "roma": romaLrc};
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

  /// 切换我喜欢状态
  /// @param isLove 默认不传为根据现有状态取反，传了就是指定状态
  toggleLove({Music? music, bool? isLove}) {
    Music? _music = music;
    if (music == null) {
      _music = playingMusic.value;
    }
    DBLogic.to.updateLove(_music!, isLove: isLove).then((value) {
      // 切换的歌曲如果是当前播放的歌曲，需要手动深拷贝一下对象使得player界面状态正确
      if (value.musicId == playingMusic.value.musicId) {
        playingMusic.value = Music.deepClone(value);
      }
      DBLogic.to.findAllLoveListByGroup(GlobalLogic.to.currentGroup.value);
    });
  }

  /// 拖拽到指定位置播放
  seekTo(int ms) {
    mPlayer.seek(Duration(milliseconds: ms));
  }

  /// 切换循环模式
  Future<void> changeLoopMode(int index) async {
    // 先设置随机模式，再设置循环模式，否则监听到的流会遗漏随机状态
    final enableShuffle = index == 0;
    await mPlayer.setShuffleModeEnabled(enableShuffle);
    if (enableShuffle) {
      await mPlayer.shuffle();
    }
    // 特殊处理随机播放：当处于LoopMode.off模式时，更改为循环列表且随机洗牌
    mPlayer.setLoopMode(
        loopModes[index] == LoopMode.off ? LoopMode.all : loopModes[index]);
    await SpUtil.put(Const.spLoopMode, index);
  }

  /// 删除播放列表中的一首歌曲
  Future<void> removeMusic(int index) async {
    audioSourceList.removeAt(index);

    // 删除的是最后一首歌，将播放列表第一首
    final music = await DBLogic.to.findMusicByMusicId(
        mPlayList[mPlayList.length == index ? 0 : index].musicId);
    playingMusic.value = music!;
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
