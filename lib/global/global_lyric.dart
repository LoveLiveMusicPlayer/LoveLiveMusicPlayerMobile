import 'package:flutter_lyric/lyric_parser/parser_smart.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/lyric.dart';
import 'package:lovelivemusicplayer/models/playing_jp_lyric.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class LyricLogic {
  LyricLogic._();

  // 当前播放歌曲日文解析后的列表
  static final parsedJPLrc = [];

  // 播放位置
  static final playingPosition = const Duration(milliseconds: 0).obs;

  // 当前播放的歌词
  static final playingJPLrc = JpLrc().obs;

  // 全量歌词
  static final fullLrc = Lyric().obs;

  // 切换显示歌词类型 (0:原文; 1:翻译; 2:罗马音)
  static final lrcType = SDUtils.allowEULA ? 0.obs : 1.obs;

  // 检查过的歌词索引，避免重复解析歌词引起cpu性能损耗
  static int mLrcIndex = -1;

  // 滚动歌词
  static final Rx<LyricsReaderModel?> lyricsModel = LyricsReaderModel().obs;

  /// 解析前一句、当前、后一句歌词内容
  static void parsePlayingLyric(String musicId, int index, bool isLast) {
    final jpLrc = parsedJPLrc;
    index = _clamp(index, 0, jpLrc.length - 1);

    final pre = (index > 0) ? (jpLrc[index - 1].mainText ?? "") : "";
    final current = jpLrc[index].mainText ?? "";
    String next = "";
    if (isLast && index < jpLrc.length - 1) {
      next = jpLrc[index + 1].mainText ?? "";
    }

    setPlayingJPLrc(musicId, pre, current, next);
  }

  static int _clamp(int value, int min, int max) {
    return value < min ? min : (value > max ? max : value);
  }

  /// 修改前一句、当前、后一句歌词内容
  static Future<void> changePlayingLyric(Duration duration,
      {bool isForce = false}) async {
    final musicId = PlayerLogic.to.playingMusic.value.musicId;
    if (musicId == null || playingJPLrc.value.musicId != musicId) {
      return;
    }

    final currentTime = duration.inMilliseconds;
    int left = 0;
    final jpLrc = parsedJPLrc;
    int right = jpLrc.length - 1;

    while (left <= right) {
      int mid = left + (right - left) ~/ 2;
      final curLrcStartTime = jpLrc[mid].startTime ?? 0;
      final nextLrcStartTime = (mid < jpLrc.length - 1)
          ? jpLrc[mid + 1].startTime ?? 0
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

    if (left < jpLrc.length) {
      final lastLrcStartTime = jpLrc[left].startTime ?? 0;
      if (lastLrcStartTime <= currentTime) {
        if (isForce || !checkedLyricIndex(left)) {
          parsePlayingLyric(musicId, left, false);
        }
      }
    }
  }

  /// 设置封面下面的歌词
  static setPlayingJPLrc([musicId = "", pre = "", current = "", next = ""]) {
    playingJPLrc.value =
        JpLrc(musicId: musicId, pre: pre, current: current, next: next);
  }

  /// 检查是否检测过该Lyric索引，如果检测过就跳过节约cpu性能
  static bool checkedLyricIndex(int index) {
    if (index == mLrcIndex) {
      return true;
    }
    mLrcIndex = index;
    return false;
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
    parsedJPLrc.clear();
    parsedJPLrc.addAll(ParserSmart(jpLrc).parseLines());
    LyricLogic.setPlayingJPLrc(PlayerLogic.to.playingMusic.value.musicId ?? "");
    LyricLogic.changePlayingLyric(playingPosition.value, isForce: true);
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
