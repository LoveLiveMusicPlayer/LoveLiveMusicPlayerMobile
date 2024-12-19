import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/lyric.dart';
import 'package:lovelivemusicplayer/models/playing_lyric.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/home_widget_util.dart';
import 'package:lovelivemusicplayer/utils/desktop_lyric_util.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class LyricLogic {
  LyricLogic._();

  // 播放位置
  static final playingPosition = const Duration(milliseconds: 0).obs;

  // 当前播放的歌词
  static final playingJPLrc = PlayingLyric().obs;

  // 全量歌词
  static final fullLrc = Lyric().obs;

  // 切换显示歌词类型 (0:原文; 1:翻译; 2:罗马音)
  static final lrcType = SDUtils.allowEULA ? 0.obs : 1.obs;

  // 滚动歌词
  static final Rx<LyricsReaderModel?> lyricsModel = LyricsReaderModel().obs;

  /// 修改当前、后一句歌词内容
  static Future<void> changePlayingLyric() async {
    final musicId = PlayerLogic.to.playingMusic.value.musicId;
    if (musicId == null || playingJPLrc.value.musicId != musicId) {
      return;
    }
    final currentTime = playingPosition.value.inMilliseconds;
    final lyricModel = lyricsModel.value;
    if (lyricModel == null) {
      return;
    }

    final curIndex = lyricModel.getCurrentLine(currentTime);
    final curLyricModel = lyricModel.lyrics[curIndex];
    var current = curLyricModel.mainText ?? "";
    var next = "";
    if (curLyricModel.hasExt) {
      next = curLyricModel.extText ?? "";
    } else {
      if (curIndex < lyricModel.lyrics.length - 1) {
        next = lyricModel.lyrics[curIndex + 1].mainText ?? "";
      }
    }
    setPlayingJPLrc(musicId, current, next);
  }

  /// 设置封面下面的歌词
  static setPlayingJPLrc([musicId = "", current = "", next = ""]) {
    playingJPLrc.value =
        PlayingLyric(musicId: musicId, current: current, next: next);
    DesktopLyricUtil.updateLyric(current, next);
    HomeWidgetUtil.sendSongInfoAndUpdate(curLyric: current, nextLyric: next);
  }

  /// 获取中/日/罗马歌词
  static Future<void> getLrc(bool forceRefresh) async {
    final uid = PlayerLogic.to.playingMusic.value.musicId;
    if (uid == null) {
      return;
    }

    var jpLrc = "";
    var zhLrc = "";
    var romaLrc = "";

    final baseUrl = PlayerLogic.to.playingMusic.value.baseUrl!;
    final lyric = PlayerLogic.to.playingMusic.value.musicPath!
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

    fullLrc.value = Lyric(jp: jpLrc, zh: zhLrc, roma: romaLrc);
    LyricLogic.setPlayingJPLrc(PlayerLogic.to.playingMusic.value.musicId);
    LyricLogic.changePlayingLyric();
    if (forceRefresh) {
      SmartDialog.showToast(fetchResultStr);
    }
  }

  /// 处理歌词二级缓存
  /// @param type 要处理的歌词类型
  /// @param lrcUrl 歌词的网络地址
  /// @param uid 歌曲的id
  /// @param forceRefresh 是否强制刷新歌词
  static Future<String?> handleLRC(
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
  static toggleTranslate() {
    lrcType.value = (lrcType.value + 1) % 3;
  }

  /// 歌词类型按钮图标
  static dynamic renderIcon() {
    switch (lrcType.value) {
      case 0:
        return Assets.playerPlayJp;
      case 1:
        return Assets.playerPlayZh;
      case 2:
        return Assets.playerPlayRoma;
    }
  }

  /// 根据选择的歌词类型创建滚动歌词模型
  static LyricsReaderModel? createLyricsModel() {
    switch (lrcType.value) {
      case 0:
        return LyricsModelBuilder.create()
            .bindLyricToMain(fullLrc.value.jp ?? "")
            .getModel();
      case 1:
        if (SDUtils.allowEULA) {
          return LyricsModelBuilder.create()
              .bindLyricToMain(fullLrc.value.jp ?? "")
              .bindLyricToExt(fullLrc.value.zh ?? "")
              .getModel();
        } else {
          return LyricsModelBuilder.create()
              .bindLyricToMain(fullLrc.value.zh ?? "")
              .bindLyricToExt(fullLrc.value.roma ?? "")
              .getModel();
        }
      case 2:
        return LyricsModelBuilder.create()
            .bindLyricToMain(fullLrc.value.jp ?? "")
            .bindLyricToExt(fullLrc.value.roma ?? "")
            .getModel();
    }
    return null;
  }
}
