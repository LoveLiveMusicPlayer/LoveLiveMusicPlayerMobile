import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';

class PipUtil {
  static const MethodChannel _channel = MethodChannel('pip');

  PipUtil._();

  static Future<bool> startPip() async {
    if (!PlayerLogic.to.mPlayer.playing) {
      SmartDialog.showToast("need_play_music_first".tr);
      return false;
    }
    return await _channel.invokeMethod("start");
  }

  static Future<bool> stopPip() async {
    return await _channel.invokeMethod("stop");
  }

  static Future<bool> updateLyric(String curLyric, String nextLyric) async {
    return await _channel
        .invokeMethod("update", {'current': curLyric, 'next': nextLyric});
  }
}
