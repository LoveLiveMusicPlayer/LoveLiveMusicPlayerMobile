import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_lyric.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:workmanager/workmanager.dart';

class HomeWidgetUtil {
  static const iosName = "HomeWidgetExample";
  static const MethodChannel _channel = MethodChannel('refreshWidgetPhoto');

  static init() async {
    await HomeWidget.setAppGroupId(Const.homeWidgetGroupId);
    await HomeWidget.initiallyLaunchedFromHomeWidget()
        .then(_launchedFromWidget);
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
    if (Platform.isAndroid) {
      _startBackgroundUpdate();
    }
  }

  static Future<void> sendSongInfoAndUpdate([Music? music]) async {
    await _sendSongData(music);
    final jpLrc = LyricLogic.playingJPLrc.value;
    await _sendSongLyric(jpLrc.current ?? "", jpLrc.next ?? "");
    await _updateWidget();
  }

  static _launchedFromWidget(Uri? uri) {
    if (uri != null) {
      SmartDialog.showToast("App started from HomeScreenWidget");
    }
  }

  static Future _sendSongData(Music? music) async {
    if (music == null) {
      return Future.value(false);
    }
    final isPlaying = PlayerLogic.to.mPlayer.playing;
    final List<Future<dynamic>> workArr = [];
    workArr.add(_channel.invokeMethod(
        'shareImage', {'path': SDUtils.getImgPathFromMusic(music)}));
    workArr.add(HomeWidget.saveWidgetData<String>('songName', music.musicName));
    workArr.add(HomeWidget.saveWidgetData<String>('songArtist', music.artist));
    workArr.add(HomeWidget.saveWidgetData<bool>('songFavorite', music.isLove));
    workArr.add(HomeWidget.saveWidgetData<bool>('isPlaying', isPlaying));
    workArr.add(HomeWidget.saveWidgetData<String>(
        'playText', isPlaying ? "playing".tr : "paused".tr));
    try {
      return Future.wait(workArr);
    } on PlatformException catch (exception) {
      print('Error Sending Data. $exception');
    }
  }

  static Future _sendSongLyric(String current, String next) async {
    final List<Future<dynamic>> workArr = [];
    workArr.add(HomeWidget.saveWidgetData<String>('curJpLrc', current));
    workArr.add(HomeWidget.saveWidgetData<String>('nextJpLrc', next));
    try {
      return Future.wait(workArr);
    } on PlatformException catch (exception) {
      print('Error Sending Data. $exception');
    }
  }

  static Future _updateWidget() async {
    try {
      return Future.wait([
        HomeWidget.updateWidget(
            iOSName: iosName, qualifiedAndroidName: Const.androidReceiverName)
      ]);
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

  static _stopBackgroundUpdate() {
    Workmanager().cancelByUniqueName('1');
  }
}
