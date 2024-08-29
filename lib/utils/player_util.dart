import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/box_decoration.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class PlayerUtil {
  PlayerUtil._();

  /// 计算真实的循环模式
  static LoopMode calcLoopMode(LoopMode? lm) {
    var loopMode = lm ?? LoopMode.off;
    if (loopMode == LoopMode.all && PlayerLogic.to.mPlayer.shuffleModeEnabled) {
      loopMode = LoopMode.off;
    }
    return loopMode;
  }

  /// 根据当前循环模式获取图片资源路径
  static getLoopIconFromLoopMode(LoopMode loopMode) {
    final index = LoopMode.values.indexOf(loopMode);
    return PlayerLogic.playerPlayIcons[index];
  }

  /// 通过点击按钮切换循环模式
  static changeLoopModeByLoopTap(LoopMode loopMode) {
    final currentIndex = LoopMode.values.indexOf(loopMode);
    final nextIndex = (currentIndex + 1) % LoopMode.values.length;
    PlayerLogic.to.changeLoopMode(LoopMode.values[nextIndex]);
  }

  /// 生成一个播放URI
  static UriAudioSource? genAudioSourceUri(Music music) {
    Uri musicUri;
    if (music.existFile == true) {
      if (!SDUtils.checkMusicExist(music)) {
        return null;
      }
      final filePath = '${SDUtils.path}${music.baseUrl}${music.musicPath}';
      musicUri = Uri.file(filePath);
    } else if (GlobalLogic.to.remoteHttp.canUseHttpUrl()) {
      musicUri = Uri.parse(
          '${GlobalLogic.to.remoteHttp.httpUrl.value}${music.baseUrl}${AppUtils.wav2flac(music.musicPath)}');
    } else {
      return null;
    }
    Uri? coverUri;
    if (music.coverPath == null || music.coverPath!.isEmpty) {
      coverUri = Uri.parse(Assets.logoLogo);
    } else if (music.existFile == true) {
      coverUri = Uri.file('${SDUtils.path}${music.baseUrl}${music.coverPath}');
    } else if (GlobalLogic.to.remoteHttp.canUseHttpUrl()) {
      coverUri = Uri.parse(
          '${GlobalLogic.to.remoteHttp.httpUrl.value}${music.baseUrl}${music.coverPath}');
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

  static refreshMiniPlayerBoxDecorationData() {
    AppUtils.getImagePaletteFromMusic(PlayerLogic.to.playingMusic.value)
        .then((color) {
      GlobalLogic.to.iconColor.value = color ?? Get.theme.primaryColor;
      final boxDecorationData = BoxDecorationData(
        color: GlobalLogic.to.iconColor.value.value,
        borderRadius: 34.r,
      );

      if (PlayerLogic.to.miniPlayerBoxDecorationData == null) {
        PlayerLogic.to.miniPlayerBoxDecorationData =
            Rx<BoxDecorationData>(boxDecorationData);
      } else {
        PlayerLogic.to.miniPlayerBoxDecorationData!.value = boxDecorationData;
      }
    });
  }
}
