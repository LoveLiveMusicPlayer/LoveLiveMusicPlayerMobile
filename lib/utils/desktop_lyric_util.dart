import 'package:flutter/services.dart';
import 'package:lovelivemusicplayer/global/global_lyric.dart';

class DesktopLyricUtil {
  static const MethodChannel _channel = MethodChannel('desktop_lyric');

  DesktopLyricUtil._();

  static init() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "lyricType") {
        LyricLogic.toggleTranslate();
      }
    });
  }

  static Future<bool> invokeStatus(bool isOpen) async {
    if (isOpen) {
      return await _start();
    } else {
      return await _stop();
    }
  }

  static Future<bool> _start() async {
    return await _channel.invokeMethod("start");
  }

  static Future<bool> _stop() async {
    return await _channel.invokeMethod("stop");
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
}
