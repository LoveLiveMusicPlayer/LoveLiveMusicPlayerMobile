import 'package:flutter/services.dart';
import 'package:lovelivemusicplayer/global/global_lyric.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';

class DesktopLyricUtil {
  static const MethodChannel _channel = MethodChannel('desktop_lyric');

  DesktopLyricUtil._();

  static init() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "lyricType") {
        LyricLogic.toggleTranslate();
        LyricLogic.changePlayingLyric(true);
        return true;
      } else if (call.method == "isPlaying") {
        return PlayerLogic.to.mPlayer.playerState.playing;
      }
    });
  }

  static Future<bool> pipAutoOpen(bool isOpen) async {
    return await _channel.invokeMethod("pipAutoOpen", isOpen);
  }

  static Future<bool> updateLyric(
      String? lyricLine1, String? lyricLine2, int currentLine) async {
    final json = {
      'lyricLine1': lyricLine1,
      'lyricLine2': lyricLine2,
      'currentLine': currentLine
    };
    return await _channel.invokeMethod("update", json);
  }

  static Future<void> sendIsPlaying(bool isPlaying) async {
    return await _channel.invokeMethod("isPlaying", isPlaying);
  }
}
