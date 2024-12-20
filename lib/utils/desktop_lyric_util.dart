import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_lyric.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';

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

  static bool isApple() => Platform.isIOS || Platform.isMacOS;

  static Future<bool> start() async {
    if (isApple() && !PlayerLogic.to.mPlayer.playing) {
      SmartDialog.showToast("need_play_music_first".tr);
      return false;
    }
    return await _channel.invokeMethod("start");
  }

  static Future<bool> stop() async {
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
