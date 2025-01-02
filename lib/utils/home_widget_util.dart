import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:workmanager/workmanager.dart';

class HomeWidgetUtil {
  static const iosNameWhite = "HomeWidgetExampleWhite";
  static const iosNameBlack = "HomeWidgetExampleBlack";
  static const androidNameWhiteSmall =
      "${Const.androidReceiverName}small_home_widget.WhiteSmallHomeWidgetReceiver";
  static const androidNameBlackSmall =
      "${Const.androidReceiverName}small_home_widget.BlackSmallHomeWidgetReceiver";
  static const androidNameWhiteLarge =
      "${Const.androidReceiverName}large_home_widget.WhiteLargeHomeWidgetReceiver";
  static const androidNameBlackLarge =
      "${Const.androidReceiverName}large_home_widget.BlackLargeHomeWidgetReceiver";
  static const MethodChannel _channel = MethodChannel('refreshWidgetPhoto');

  static init() async {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await HomeWidget.setAppGroupId(Const.homeWidgetGroupId);
    if (Platform.isAndroid) {
      _startBackgroundUpdate();
    }
  }

  static Future<void> sendSongInfoAndUpdate(
      {Music? music,
      String? lyricLine1,
      String? lyricLine2,
      int currentLine = 1}) async {
    await _sendSongData(music);
    await _sendSongLyric(lyricLine1, lyricLine2, currentLine);
    await _updateWidget();
  }

  static Future _sendSongData(Music? music) async {
    if (music == null) {
      return Future.value(false);
    }
    final isPlaying = PlayerLogic.to.mPlayer.playing;
    final List<Future<dynamic>> workArr = [];
    final imagePath = SDUtils.getImgPathFromMusic(music);
    workArr.add(_channel.invokeMethod('shareImage', {'path': imagePath}));
    workArr.add(HomeWidget.saveWidgetData<String>('songName', music.musicName));
    workArr.add(HomeWidget.saveWidgetData<String>('songArtist', music.artist));
    workArr.add(HomeWidget.saveWidgetData<bool>('songFavorite', music.isLove));
    workArr.add(HomeWidget.saveWidgetData<bool>('isPlaying', isPlaying));
    workArr.add(HomeWidget.saveWidgetData<String>(
        'playText', '${"playing".tr},${"paused".tr}'));
    try {
      return Future.wait(workArr);
    } on PlatformException catch (exception) {
      print('Error Sending Data. $exception');
    }
  }

  static Future _sendSongLyric(
      String? lyricLine1, String? lyricLine2, int currentLine) async {
    final List<Future<dynamic>> workArr = [];
    workArr.add(HomeWidget.saveWidgetData<String>('lyricLine1', lyricLine1));
    workArr.add(HomeWidget.saveWidgetData<String>('lyricLine2', lyricLine2));
    workArr.add(HomeWidget.saveWidgetData<int>('currentLine', currentLine));
    try {
      return Future.wait(workArr);
    } on PlatformException catch (exception) {
      print('Error Sending Data. $exception');
    }
  }

  static Future _updateWidget() async {
    try {
      if (Platform.isIOS) {
        await HomeWidget.updateWidget(iOSName: iosNameWhite);
        await HomeWidget.updateWidget(iOSName: iosNameBlack);
      } else {
        await HomeWidget.updateWidget(
            qualifiedAndroidName: androidNameWhiteSmall);
        await HomeWidget.updateWidget(
            qualifiedAndroidName: androidNameBlackSmall);
        await HomeWidget.updateWidget(
            qualifiedAndroidName: androidNameWhiteLarge);
        await HomeWidget.updateWidget(
            qualifiedAndroidName: androidNameBlackLarge);
      }
    } on PlatformException catch (exception) {
      print('Error Updating Widget. $exception');
    }
  }

  static _startBackgroundUpdate() {
    Workmanager().registerPeriodicTask(
      '1',
      'widgetBackgroundUpdate',
      frequency: const Duration(minutes: 5),
    );
  }
}
