import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_lyric.dart';
import 'package:lovelivemusicplayer/models/box_decoration.dart';
import 'package:lovelivemusicplayer/models/lyric.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/play_list_music.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/desktop_lyric_util.dart';
import 'package:lovelivemusicplayer/utils/home_widget_util.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:lovelivemusicplayer/utils/player_util.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;

class PlayerLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final mPlayer = AudioPlayer();

  static const playerPlayIcons = [
    Assets.playerPlayShuffle,
    Assets.playerPlaySingle,
    Assets.playerPlayRecycle,
  ];

  // 播放列表<AudioSource>
  final audioSourceList = ConcatenatingAudioSource(children: []);

  // 播放列表
  var mPlayList = <PlayListMusic>[].obs;

  // 当前播放歌曲
  var playingMusic = Music().obs;

  // 处理播放业务逻辑的进度订阅
  StreamSubscription? playerSubscription;

  final playerLogic = false.obs;

  // miniPlayer底部Box样式
  late Rx<BoxDecorationData> miniPlayerBoxDecorationData;

  static PlayerLogic get to => Get.find();

  @override
  void onInit() {
    mPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace st) {
      if (e is PlayerException) {
        Log4f.i(msg: 'player error code: ${e.code}');
        Log4f.i(msg: 'player error message: ${e.message}');
      } else {
        Log4f.i(msg: e.toString());
      }
    });

    mPlayer.playerStateStream.listen((state) {
      DesktopLyricUtil.sendIsPlaying(state.playing);
    });

    mPlayer.playingStream.listen((event) {
      HomeWidgetUtil.sendSongInfoAndUpdate(music: playingMusic.value);
    });

    /// 播放位置监听
    mPlayer.positionStream.listen((duration) {
      LyricLogic.playingPosition.value = duration;
      LyricLogic.changePlayingLyric(false);
    });

    /// 当前播放监听
    mPlayer.currentIndexStream.listen((index) async {
      if (index != null &&
          mPlayList.isNotEmpty &&
          !GlobalLogic.to.isHandlePlay) {
        final curMusic = mPlayList[index];
        Log4f.v(msg: "当前播放: $index - ${curMusic.musicName}");
        AppUtils.uploadEvent("Playing", params: {"music": curMusic.musicName});
        await changePlayingMusic(curMusic);
        await persistencePlayList(index);
        await DBLogic.to.refreshMusicTimestamp(curMusic.musicId);
        GlobalLogic.to.isHandlePlay = false;
        LyricLogic.getLrc(false);
      }
    });

    // 对两个stream进行捆绑订阅
    playerSubscription =
        rx_dart.CombineLatestStream.combine2<PlayerState, bool, void>(
            mPlayer.playerStateStream, playerLogic.stream,
            (processState, isHandled) {
      // 当状态不为缓冲中，并且播放逻辑执行完毕
      if (processState.processingState != ProcessingState.loading &&
          isHandled) {
        SmartDialog.dismiss(status: SmartStatus.loading);
      }
    }).listen(null);

    LyricLogic.fullLrc.stream.listen((lyric) {
      LyricLogic.lyricsModel.value = LyricLogic.createLyricsModel();
    });

    LyricLogic.lrcType.stream.listen((type) {
      LyricLogic.lyricsModel.value = LyricLogic.createLyricsModel();
    });

    super.onInit();
  }

  @override
  void dispose() {
    playerSubscription?.cancel();
    super.dispose();
  }

  Future<void> initLoopMode() async {
    final mode = await SpUtil.getInt(Const.spLoopMode, 0);
    await changeLoopMode(LoopMode.values[mode]);
  }

  /// 持久化播放列表
  Future<void> persistencePlayList(int index, {List<Music>? musicList}) async {
    if (musicList != null) {
      mPlayList.clear();
      mPlayList.addAll(musicList.cloneFromMusicList(index));
    } else {
      for (var i = 0; i < mPlayList.length; i++) {
        mPlayList[i].isPlaying = index == i;
      }
    }
    await DBLogic.to.updatePlayingList(mPlayList);
  }

  /// 修改当前播放的歌曲
  Future<void> changePlayingMusic(PlayListMusic currentMusic) async {
    if (playingMusic.value.musicId != currentMusic.musicId) {
      final music = await DBLogic.to.findMusicById(currentMusic.musicId);
      if (music != null) {
        setCurrentMusic(music);
      }
    }
  }

  /// 播放指定列表的歌曲
  Future<void> playMusic(List<Music> musicList,
      {int? mIndex, bool needPlay = true, bool showDialog = true}) async {
    if (musicList.isEmpty) {
      return;
    }
    if (GlobalLogic.to.isCanUseSmartDialog && showDialog) {
      SmartDialog.showLoading(msg: 'loading'.tr);
    }
    playerLogic.value = false;
    bool isNoneExist = true;
    for (var i = 0; i < musicList.length; i++) {
      final isExist = SDUtils.checkMusicExist(musicList[i]);
      musicList[i].isExist = isExist;
      if (isNoneExist && isExist) {
        isNoneExist = false;
      }
    }
    if (isNoneExist) {
      return;
    }

    // 随机播放时任取一个index
    int index = mIndex ?? 0;
    if (index < musicList.length && !musicList[index].isExist) {
      // 如果指定的索引 mIndex 无效或对应的文件不存在
      int nextExistIndex = -1;
      for (var i = index + 1; i < musicList.length; i++) {
        if (musicList[i].isExist) {
          nextExistIndex = i;
          break;
        }
      }
      if (nextExistIndex != -1) {
        index = nextExistIndex;
      } else {
        // 如果没有找到下一个存在的文件，则直接返回
        return;
      }
    }
    if (mIndex == null && mPlayer.shuffleModeEnabled) {
      index = Random().nextInt(musicList.length);
    }
    AppUtils.uploadEvent("Playing",
        params: {"music": musicList[index].musicName ?? ""});
    print("播放曲目: ${musicList[index].musicName}");
    try {
      // 如果上一次处理没有结束，直接跳过
      if (GlobalLogic.to.isHandlePlay) {
        Log4f.d(msg: "事件：正在处理中，跳过...");
        return;
      }
      GlobalLogic.to.isHandlePlay = true;
      if (musicList.isEmpty) {
        GlobalLogic.to.isHandlePlay = false;
        Log4f.d(msg: "事件：列表为空");
        return;
      }

      // 设置新的播放列表
      final audioList = <AudioSource>[];
      for (var music in musicList) {
        final genMusic = PlayerUtil.genAudioSourceUri(music);
        if (genMusic == null) {
          continue;
        }
        audioList.add(genMusic);
      }
      await mPlayer.pause();
      await mPlayer.stop();
      await audioSourceList.clear();
      if (audioList.isEmpty) {
        SmartDialog.dismiss();
        SmartDialog.showToast('now_can_not_play'.tr);
        return;
      }
      await audioSourceList.addAll(audioList);
      audioList.clear();
      print("播放列表长度: ${audioSourceList.length}");
      mPlayer
          .setAudioSource(audioSourceList, initialIndex: index)
          .then((duration) {
        if (needPlay) {
          mPlayer.play();
        }
      });
      await persistencePlayList(index, musicList: musicList);
      if (playingMusic.value != musicList[index]) {
        setCurrentMusic(musicList[index]);
      }
      await DBLogic.to.refreshMusicTimestamp(musicList[index].musicId!);
      LyricLogic.getLrc(false);
      playerLogic.value = true;
    } catch (e) {
      Log4f.i(msg: e.toString());
    } finally {
      GlobalLogic.to.isHandlePlay = false;
    }
  }

  /// 插入到下一曲
  /// @param isNext true: 插入下一首; false: 插入末尾
  Future<void> addNextMusic(Music music, {bool isNext = true}) async {
    if (music.musicId == playingMusic.value.musicId) {
      // 如果选中的歌曲是当前播放的歌曲
      return;
    }

    final genMusic = PlayerUtil.genAudioSourceUri(music);
    if (genMusic == null) {
      return;
    }

    final pMusic = PlayListMusic(
        musicId: music.musicId!,
        musicName: music.musicName!,
        artist: music.artist!);

    // 如果列表为空则直接播放
    if (mPlayList.isEmpty) {
      playMusic([music]);
      return;
    }

    int mIndex = -1;
    // 搜索并删除当前要插入的歌曲
    for (var index = 0; index < mPlayList.length; index++) {
      if (mPlayList[index].musicId == music.musicId) {
        mIndex = index;
        break;
      }
    }

    if (mIndex >= 0) {
      mPlayList.removeAt(mIndex);
      await DBLogic.to.updatePlayingList(mPlayList);
      await audioSourceList.removeAt(mIndex);
    }

    mIndex = -1;

    if (isNext) {
      // 将插入的歌曲放在当前播放歌曲的后面
      for (var index = 0; index < mPlayList.length; index++) {
        if (mPlayList[index].musicId == playingMusic.value.musicId) {
          mIndex = index;
          break;
        }
      }

      if (mIndex >= 0) {
        mPlayList.insert(mIndex + 1, pMusic);
        await DBLogic.to.updatePlayingList(mPlayList);
        await audioSourceList.insert(mIndex + 1, genMusic);
      }
    } else {
      mPlayList.insert(mPlayList.length, pMusic);
      await DBLogic.to.updatePlayingList(mPlayList);
      await audioSourceList.insert(audioSourceList.length, genMusic);
    }
  }

  /// 将音乐列表插入到当前播放列表末尾
  Future<bool> addMusicList(List<Music> musicList) async {
    if (musicList.isEmpty) {
      return false;
    }
    // 如果列表为空则直接播放
    if (mPlayList.isEmpty) {
      playMusic(musicList);
      return true;
    }

    // 从音乐列表中重复的歌曲删除
    Set<String> mPlayListIds =
        Set<String>.from(mPlayList.map((item) => item.musicId));
    for (var index = 0; index < musicList.length; index++) {
      if (mPlayListIds.contains(musicList[index].musicId)) {
        musicList.removeAt(index);
        index--;
        break;
      }
    }

    // 将音乐列表插入到播放列表队尾
    await Future.forEach(musicList, (Music music) async {
      final genMusic = PlayerUtil.genAudioSourceUri(music);
      if (genMusic != null) {
        await audioSourceList.add(genMusic);
        mPlayList.add(PlayListMusic(
            musicId: music.musicId!,
            musicName: music.musicName!,
            artist: music.artist!));
        await DBLogic.to.updatePlayingList(mPlayList);
      }
    });
    return true;
  }

  /// 开关播放
  togglePlay() {
    if (PlayerLogic.to.playingMusic.value.musicId == null) {
      return;
    }
    if (mPlayer.playing) {
      mPlayer.pause();
    } else {
      mPlayer.play();
    }
  }

  /// 切换我喜欢状态
  /// @param isLove 默认不传为根据现有状态取反，传了就是指定状态
  Future<void> toggleLove({Music? music, bool? isLove}) async {
    Music? mMusic = music;
    mMusic ??= playingMusic.value;
    if (mMusic.musicId == null) {
      return;
    }
    final tempMusic = await DBLogic.to.updateLove(mMusic, isLove: isLove);
    // 切换的歌曲如果是当前播放的歌曲，需要手动深拷贝一下对象使得player界面状态正确
    if (tempMusic != null && tempMusic.musicId == playingMusic.value.musicId) {
      print("isLove: ${tempMusic.musicName} ${tempMusic.isLove}");
      setCurrentMusic(Music.deepClone(tempMusic));
    }
    await DBLogic.to.findAllLoveListByGroup(GlobalLogic.to.currentGroup.value);
  }

  /// 切换我喜欢状态（列表）
  /// @param musicList 选中的歌曲列表
  /// @param changeStatus 要修改的状态
  Future<void> toggleLoveList(List<Music> musicList, bool changeStatus) async {
    await DBLogic.to.updateLoveList(musicList, changeStatus);
    final music = playingMusic.value;
    final hasPlayingMusic =
        musicList.any((element) => element.musicId == music.musicId);
    if (hasPlayingMusic) {
      playingMusic.value.isLove = !playingMusic.value.isLove;
    }
    await DBLogic.to.findAllLoveListByGroup(GlobalLogic.to.currentGroup.value);
  }

  /// 拖拽到指定位置并播放
  Future<void> seekToPlay(dynamic ms) async {
    if (ms is int) {
      await mPlayer.seek(Duration(milliseconds: ms));
    } else if (ms is Duration) {
      await mPlayer.seek(ms);
    }
    if (!mPlayer.playing) {
      mPlayer.play();
    }
  }

  /// 切换循环模式
  /// @param loopMode
  /// LoopMode.off 随机循环
  /// LoopMode.one 单曲循环
  /// LoopMode.all 列表循环
  Future<void> changeLoopMode(LoopMode loopMode) async {
    // 先设置随机模式，再设置循环模式，否则监听到的流会遗漏随机状态
    final enableShuffle = loopMode == LoopMode.off;
    await mPlayer.setShuffleModeEnabled(enableShuffle);
    if (enableShuffle) {
      await mPlayer.shuffle();
    }
    // 特殊处理随机播放：当处于随机模式时，更改为循环列表且随机洗牌
    mPlayer.setLoopMode(loopMode == LoopMode.off ? LoopMode.all : loopMode);
    SpUtil.put(Const.spLoopMode, LoopMode.values.indexOf(loopMode));
  }

  /// 删除播放列表中的一首歌曲
  Future<void> removeMusic(int index) async {
    if (audioSourceList.length == 1) {
      // 播放列表仅剩一个则停止播放，清空状态
      mPlayList.removeAt(index);
      await DBLogic.to.updatePlayingList(mPlayList);
      await clearPlayerStatus();
      await audioSourceList.removeAt(index);
      return;
    }

    final currentMusic = playingMusic.value;
    final chooseMusic = mPlayList[index];

    if (currentMusic.musicId != chooseMusic.musicId) {
      // 删除非当前播放的歌曲
      mPlayList.removeAt(index);
      await DBLogic.to.updatePlayingList(mPlayList);
      await audioSourceList.removeAt(index);
      return;
    }
    // 删除当前播放的歌曲
    mPlayList.removeAt(index);
    await DBLogic.to.updatePlayingList(mPlayList);
    // 随机播放时任取一个index
    int mIndex;
    if (mPlayer.shuffleModeEnabled) {
      // 随机播放，随机再获取一个索引
      mIndex = Random().nextInt(mPlayList.length);
    } else {
      // 顺序播放或单曲循环，查看当前索引是否越界
      if (index > mPlayList.length - 1) {
        // 越界则从头开始播放
        mIndex = 0;
      } else {
        // 不越界仍播放当前索引歌曲
        mIndex = index;
      }
    }
    await DBLogic.to.findAllPlayListMusics(
        willPlayMusicIndex: mIndex, needPlay: mPlayer.playing);
  }

  /// 删除播放列表中全部歌曲
  Future<void> removeAllMusics() async {
    await clearPlayerStatus();
    await audioSourceList.clear();
    await DBLogic.to.playListMusicDao.deleteAllPlayListMusics();
  }

  /// 停止播放，清空状态
  Future<void> clearPlayerStatus() async {
    await mPlayer.pause();
    await mPlayer.stop();
    setCurrentMusic(null);
    LyricLogic.postNowPlayingLyric(null);
    LyricLogic.postDesktopAndWidgetLyric(null);
    LyricLogic.fullLrc.value = Lyric();
  }

  /// 设置当前播放歌曲
  setCurrentMusic(Music? music) async {
    HomeWidgetUtil.sendSongInfoAndUpdate(music: music);
    if (Platform.isIOS) {
      Carplay.changePlayingMusic(music);
    }
    if (music == null) {
      playingMusic.value = Music();
    } else {
      var isLove = await DBLogic.to.loveDao.findLoveById(music.musicId!);
      music.isLove = isLove != null;
      playingMusic.value = music;
    }
    // 取歌曲主颜色生成miniPlayer的BoxDecorationData
    PlayerUtil.refreshMiniPlayerBoxDecorationData();
  }

  /// 按钮点击上一曲
  playPrev() {
    if (mPlayer.hasPrevious) {
      mPlayer.seekToPrevious();
      // LyricLogic.postNowPlayingLyric(null);
    }
  }

  /// 按钮点击下一曲
  playNext() {
    if (mPlayer.hasNext) {
      mPlayer.seekToNext();
      // LyricLogic.postNowPlayingLyric(null);
    }
  }
}
