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
import 'package:lovelivemusicplayer/utils/desktop_lyric_util.dart';
import 'package:lovelivemusicplayer/utils/home_widget_util.dart';
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

  // 指示已经处理过的歌词，播放器一句歌词会回调很多次，避免性能损耗
  static int latestCurIndex = 0;

  // 记录解析后的歌词信息，便于后续判断新解析的歌词替换哪一个变量
  static String? originLine1Text;
  static String? originLine2Text;

  /// 修改当前、后一句歌词内容
  static Future<void> changePlayingLyric(bool isFetch) async {
    final musicId = PlayerLogic.to.playingMusic.value.musicId;
    if (musicId == null || playingJPLrc.value.musicId != musicId) {
      return;
    }
    final currentTime = playingPosition.value.inMilliseconds;
    final lyricModel = lyricsModel.value;
    if (lyricModel == null || lyricModel.lyrics.isEmpty) {
      // 暂无歌词
      postNowPlayingLyric(musicId, 'no_lyrics'.tr, "");
      postDesktopAndWidgetLyric(musicId, 'no_lyrics'.tr, "", -1);
      return;
    }

    final curIndex = lyricModel.getCurrentLine(currentTime);
    if (isFetch) {
      latestCurIndex = -1;
    }
    if (curIndex == latestCurIndex) {
      // 解析过当句歌词就停止后续解析
      return;
    }
    latestCurIndex = curIndex;

    final curLyricModel = lyricModel.lyrics[curIndex];
    final mainText = curLyricModel.mainText?.replaceLine();
    String? extText;

    if (lrcType.value > 0) {
      // 中译/罗马
      if (curLyricModel.hasExt) {
        // 日文对应的 中译/罗马
        extText = curLyricModel.extText?.replaceLine();
      }
      // 如果日文为空字符串，强制将副文本替换为空字符串
      if (mainText?.isEmpty == true) {
        extText = "";
      }
      postNowPlayingLyric(musicId, mainText, extText);
      postDesktopAndWidgetLyric(musicId, mainText, extText, 0);
      return;
    }

    // 原文
    if (curIndex < lyricModel.lyrics.length - 1) {
      // 下一句播放的歌词
      extText = lyricModel.lyrics[curIndex + 1].mainText?.replaceLine();
    }
    postNowPlayingLyric(musicId, mainText, extText);

    if (isFetch) {
      // 切歌，需要重新将每一行歌词都替换掉
      postDesktopAndWidgetLyric(musicId, mainText, extText);
      return;
    }

    if (mainText == originLine1Text) {
      // 如果当前播放的歌词被上一次解析过，记录为line1，则需要将下一句歌词用line2替换
      postDesktopAndWidgetLyric(musicId, null, extText);
      return;
    }

    if (mainText == originLine2Text) {
      // 如果当前播放的歌词被上一次解析过，记录为line2，则需要将下一句歌词用line1替换
      postDesktopAndWidgetLyric(musicId, extText, null, 2);
      return;
    }

    // mainText与line1和line2均不相等时（比如：跳转播放）
    // 此时歌词面板应该强制将每一行歌词都替换掉
    postDesktopAndWidgetLyric(musicId, mainText, extText);
  }

  /// 设置封面下面的歌词
  static postNowPlayingLyric(String? musicId,
      [String? lyricLine1, String? lyricLine2]) {
    playingJPLrc.value = PlayingLyric(
        musicId: musicId, lyricLine1: lyricLine1, lyricLine2: lyricLine2);
  }

  /// 设置桌面歌词和小组件歌词
  static postDesktopAndWidgetLyric(String? musicId,
      [String? lyricLine1, String? lyricLine2, int currentLine = 1]) {
    // 只要变量不为null（空字符串或者多字符字符串），就记录到变量中
    if (lyricLine1 != null) {
      originLine1Text = lyricLine1;
    }
    if (lyricLine2 != null) {
      originLine2Text = lyricLine2;
    }
    HomeWidgetUtil.sendSongInfoAndUpdate(
        lyricLine1: lyricLine1,
        lyricLine2: lyricLine2,
        currentLine: currentLine);
    DesktopLyricUtil.updateLyric(lyricLine1, lyricLine2, currentLine);
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
    playingJPLrc.value = PlayingLyric(
        musicId: PlayerLogic.to.playingMusic.value.musicId!,
        lyricLine1: null,
        lyricLine2: null);
    LyricLogic.changePlayingLyric(true);
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

extension StringExt on String {
  String replaceLine() {
    return replaceAll("\r", "").replaceAll("\n", "");
  }
}
