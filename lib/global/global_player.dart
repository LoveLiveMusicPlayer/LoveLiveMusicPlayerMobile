import 'dart:async';
import 'dart:math';

import 'package:flutter_lyric/lyric_parser/parser_smart.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/lyric.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/play_list_music.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';

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
  var mPlayList = <PlayListMusic>[].obs;

  // 当前播放的歌词
  var playingJPLrc = {"musicId": "", "pre": "", "current": "", "next": ""}.obs;

  // 全量歌词
  var fullLrc = {"jp": "", "zh": "", "roma": ""}.obs;

  // 当前播放歌曲日文解析后的列表
  var parsedJPLrc = [];

  // 是否需要刷新歌词UI
  var needRefreshLyric = false.obs;

  // 播放状态
  var isPlaying = false.obs;

  // 播放位置
  var playingPosition = const Duration(milliseconds: 0).obs;

  // 当前播放歌曲
  var playingMusic = Music().obs;

  // 切换显示歌词类型 (0:原文; 1:翻译; 2:罗马音)
  var lrcType = SDUtils.allowEULA ? 0.obs : 1.obs;

  // 检查过的歌词索引，避免重复解析歌词引起cpu性能损耗
  int mLrcIndex = -1;

  static PlayerLogic get to => Get.find();

  @override
  void onInit() {
    super.onInit();

    mPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace st) {
      if (e is PlayerException) {
        Log4f.i(msg: 'player error code: ${e.code}');
        Log4f.i(msg: 'player error message: ${e.message}');
      } else {
        Log4f.i(msg: e.toString());
      }
    });

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
        // 切歌后重置索引
        mLrcIndex = -1;
        Log4f.v(msg: "当前播放: $index - ${mPlayList[index].musicName}");
        AppUtils.uploadEvent("Playing",
            params: {"music": mPlayList[index].musicName});
        final currentMusic = mPlayList[index];
        await changePlayingMusic(currentMusic);
        await persistencePLayList2(mPlayList, index);
        await DBLogic.to.refreshMusicTimestamp(currentMusic.musicId);
        GlobalLogic.to.isHandlePlay = false;
        getLrc(false);
      }
    });
  }

  Future<void> initLoopMode() async {
    final mode = await SpUtil.getInt(Const.spLoopMode, 0);
    await changeLoopMode(mode);
  }

  /// 持久化播放列表
  Future<void> persistencePlayList(List<Music> musicList, int index) async {
    mPlayList.clear();
    final tempList = <PlayListMusic>[];
    for (var i = 0; i < musicList.length; i++) {
      final music = musicList[i];
      tempList.add(PlayListMusic(
          musicId: music.musicId!,
          musicName: music.musicName!,
          artist: music.artist!,
          isPlaying: index == i));
    }
    mPlayList.addAll(tempList);
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
      final music = await DBLogic.to.findMusicById(currentMusic.musicId);
      if (music != null) {
        setCurrentMusic(music);
      }
    }
  }

  /// 修改前一句、当前、后一句歌词内容
  Future<void> changePlayingLyric(Duration duration,
      {bool isForce = false}) async {
    final musicId = playingMusic.value.musicId;
    if (musicId == null || playingJPLrc["musicId"] != musicId) {
      return;
    }

    final currentTime = duration.inMilliseconds;
    int left = 0;
    int right = parsedJPLrc.length - 1;

    while (left <= right) {
      int mid = left + (right - left) ~/ 2;
      final curLrcStartTime = parsedJPLrc[mid].startTime ?? 0;
      final nextLrcStartTime = (mid < parsedJPLrc.length - 1)
          ? parsedJPLrc[mid + 1].startTime ?? 0
          : double.infinity;

      if (curLrcStartTime <= currentTime && nextLrcStartTime > currentTime) {
        if (isForce || !checkedLyricIndex(mid)) {
          parsePlayingLyric(musicId, mid, true);
        }
        return;
      } else if (curLrcStartTime < currentTime) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    if (left < parsedJPLrc.length) {
      final lastLrcStartTime = parsedJPLrc[left].startTime ?? 0;
      if (lastLrcStartTime <= currentTime) {
        if (isForce || !checkedLyricIndex(left)) {
          parsePlayingLyric(musicId, left, false);
        }
      }
    }
  }

  /// 检查是否检测过该Lyric索引，如果检测过就跳过节约cpu性能
  bool checkedLyricIndex(int index) {
    if (index == mLrcIndex) {
      return true;
    }
    mLrcIndex = index;
    return false;
  }

  /// 解析前一句、当前、后一句歌词内容
  void parsePlayingLyric(String musicId, int index, bool isLast) {
    index = _clamp(index, 0, parsedJPLrc.length - 1);

    final pre = (index > 0) ? (parsedJPLrc[index - 1].mainText ?? "") : "";
    final current = parsedJPLrc[index].mainText ?? "";
    String next = "";
    if (isLast && index < parsedJPLrc.length - 1) {
      next = parsedJPLrc[index + 1].mainText ?? "";
    }

    setPlayingJPLrc(musicId, pre, current, next);
  }

  int _clamp(int value, int min, int max) {
    return value < min ? min : (value > max ? max : value);
  }

  /// 播放指定列表的歌曲
  Future<void> playMusic(List<Music> uncheckedMusicList,
      {int? mIndex, bool needPlay = true, bool showDialog = true}) async {
    if (uncheckedMusicList.isEmpty) {
      return;
    }
    if (isCanUseSmartDialog && showDialog) {
      SmartDialog.showLoading(msg: 'loading'.tr);
    }
    final musicList = <Music>[];
    for (var i = 0; i < uncheckedMusicList.length; i++) {
      final isExist = SDUtils.checkMusicExist(uncheckedMusicList[i]);
      if (isExist) {
        musicList.add(uncheckedMusicList[i]);
      } else if (mIndex != null && mIndex > i) {
        mIndex--;
      }
    }
    // 随机播放时任取一个index
    int index = mIndex ?? 0;
    if (mIndex == null && mPlayer.shuffleModeEnabled) {
      index = Random().nextInt(musicList.length);
    }
    AppUtils.uploadEvent("Playing",
        params: {"music": musicList[index].musicName ?? ""});
    Log4f.v(msg: "播放曲目: ${musicList[index].musicName}");
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
        final genMusic = genAudioSourceUri(music);
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
      Log4f.v(msg: "播放列表长度: ${audioSourceList.length}");
      mPlayer.setAudioSource(audioSourceList, initialIndex: index);
      if (needPlay) {
        mPlayer.play();
      }
      await persistencePlayList(musicList, index);
      if (playingMusic.value != musicList[index]) {
        setCurrentMusic(musicList[index]);
      }
      await DBLogic.to.refreshMusicTimestamp(musicList[index].musicId!);
      getLrc(false);
      SmartDialog.dismiss();
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

    final genMusic = genAudioSourceUri(music);
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
        await audioSourceList.insert(mIndex + 1, genMusic);
      }
    } else {
      mPlayList.insert(mPlayList.length, pMusic);
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
      final genMusic = genAudioSourceUri(music);
      if (genMusic != null) {
        await audioSourceList.add(genMusic);
        mPlayList.add(PlayListMusic(
            musicId: music.musicId!,
            musicName: music.musicName!,
            artist: music.artist!));
      }
    });
    return true;
  }

  /// 生成一个播放URI
  UriAudioSource? genAudioSourceUri(Music music) {
    Uri musicUri;
    if (music.existFile == true) {
      if (!SDUtils.checkMusicExist(music)) {
        return null;
      }
      final filePath = '${SDUtils.path}${music.baseUrl}${music.musicPath}';
      musicUri = Uri.file(filePath);
    } else if (remoteHttp.canUseHttpUrl()) {
      musicUri = Uri.parse(
          '${remoteHttp.httpUrl.value}${music.baseUrl}${AppUtils.wav2flac(music.musicPath)}');
    } else {
      return null;
    }
    Uri? coverUri;
    if (music.coverPath == null || music.coverPath!.isEmpty) {
      coverUri = Uri.parse(Assets.logoLogo);
    } else if (music.existFile == true) {
      coverUri = Uri.file('${SDUtils.path}${music.baseUrl}${music.coverPath}');
    } else if (remoteHttp.canUseHttpUrl()) {
      coverUri = Uri.parse(
          '${remoteHttp.httpUrl.value}${music.baseUrl}${music.coverPath}');
    }
    return AudioSource.uri(
      musicUri,
      tag: MediaItem(
        id: music.musicId!,
        title: music.musicName!,
        album: music.albumName!,
        artist: music.artist,
        artUri: coverUri,
      ),
    );
  }

  /// 开关播放
  Future<void> togglePlay() async {
    if (isPlaying.value) {
      await mPlayer.pause();
    } else {
      await mPlayer.play();
    }
  }

  /// 获取中/日/罗马歌词
  Future<void> getLrc(bool forceRefresh) async {
    final uid = playingMusic.value.musicId;
    if (uid == null) {
      return;
    }

    var jpLrc = "";
    var zhLrc = "";
    var romaLrc = "";

    final baseUrl = playingMusic.value.baseUrl!;
    final lyric = playingMusic.value.musicPath!
        .replaceAll("flac", "lrc")
        .replaceAll("wav", "lrc");
    String fetchResultStr = 'search_lyric_success'.tr;
    final zh = await handleLRC("zh", "ZH/$baseUrl$lyric", uid, forceRefresh);
    if (zh == null) {
      fetchResultStr = 'search_lyric_failed'.tr;
    } else {
      zhLrc = zh;
    }
    if (SDUtils.allowEULA) {
      final jp = await handleLRC("jp", "JP/$baseUrl$lyric", uid, forceRefresh);
      if (jp == null) {
        fetchResultStr = 'search_lyric_failed'.tr;
      } else {
        jpLrc = jp;
      }
      final roma =
          await handleLRC("roma", "ROMA/$baseUrl$lyric", uid, forceRefresh);
      if (roma == null) {
        fetchResultStr = 'search_lyric_failed'.tr;
      } else {
        romaLrc = roma;
      }
    }

    fullLrc.value = {"jp": jpLrc, "zh": zhLrc, "roma": romaLrc};
    parsedJPLrc.clear();
    parsedJPLrc.addAll(ParserSmart(fullLrc["jp"]!).parseLines());
    setPlayingJPLrc(playingMusic.value.musicId ?? "");
    changePlayingLyric(playingPosition.value, isForce: true);
    if (forceRefresh) {
      SmartDialog.compatible.showToast(fetchResultStr);
    }
    Future.delayed(
        const Duration(milliseconds: 200), () => needRefreshLyric.value = true);
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
          try {
            final encodeUrl = Uri.encodeComponent(lrcUrl);
            final netLrc =
                await Network.getSync("${Const.lyricOssUrl}$encodeUrl") ?? "";
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
          } catch (error) {
            return null;
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
    lrcType.value = (lrcType.value + 1) % 3;
    needRefreshLyric.value = true;
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

  /// 拖拽到指定位置播放
  Future<void> seekTo(int ms) async {
    await mPlayer.seek(Duration(milliseconds: ms));
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
    mPlayer
        .setLoopMode(
            loopModes[index] == LoopMode.off ? LoopMode.all : loopModes[index])
        .then((value) {});
    await SpUtil.put(Const.spLoopMode, index);
  }

  /// 删除播放列表中的一首歌曲
  Future<void> removeMusic(int index) async {
    if (audioSourceList.length == 1) {
      // 播放列表仅剩一个则停止播放，清空状态
      mPlayList.removeAt(index);
      await clearPlayerStatus();
      await audioSourceList.removeAt(index);
      return;
    }

    final currentMusic = playingMusic.value;
    final chooseMusic = mPlayList[index];

    if (currentMusic.musicId != chooseMusic.musicId) {
      // 删除非当前播放的歌曲
      mPlayList.removeAt(index);
      await audioSourceList.removeAt(index);
      return;
    }
    // 删除当前播放的歌曲
    mPlayList.removeAt(index);
    await audioSourceList.removeAt(index);
  }

  /// 删除播放列表中全部歌曲
  Future<void> removeAllMusics() async {
    await clearPlayerStatus();
    await audioSourceList.clear();
  }

  /// 停止播放，清空状态
  Future<void> clearPlayerStatus() async {
    await mPlayer.pause();
    await mPlayer.stop();
    setCurrentMusic(null);
    setPlayingJPLrc();
    fullLrc.value = {"jp": "", "zh": "", "roma": ""};
    needRefreshLyric.value = true;
  }

  /// 清空封面下面的歌词
  setPlayingJPLrc([musicId = "", pre = "", current = "", next = ""]) {
    playingJPLrc.value = {
      "musicId": musicId,
      "pre": pre,
      "current": current,
      "next": next
    };
  }

  /// 设置当前播放歌曲
  setCurrentMusic(Music? music) async {
    if (music == null) {
      playingMusic.value = Music();
    } else {
      var isLove = await DBLogic.to.loveDao.findLoveById(music.musicId!);
      music.isLove = isLove != null;
      playingMusic.value = music;
      AppUtils.getImagePaletteFromMusic(playingMusic.value).then((color) {
        GlobalLogic.to.iconColor.value = color ?? Get.theme.primaryColor;
      });
    }
    Carplay.changePlayingMusic(playingMusic.value);
  }

  /// 按钮点击上一曲
  Future<void> playPrev() async {
    if (mPlayer.hasPrevious) {
      setPlayingJPLrc();
      await mPlayer.seekToPrevious();
    }
  }

  /// 按钮点击下一曲
  Future<void> playNext() async {
    if (mPlayer.hasNext) {
      setPlayingJPLrc();
      await mPlayer.seekToNext();
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {
    needRefreshLyric.value = true;
  }

  @override
  void onHidden() {}
}
