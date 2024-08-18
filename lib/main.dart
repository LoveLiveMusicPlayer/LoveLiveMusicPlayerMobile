import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lovelivemusicplayer/eventbus/close_open.dart';
import 'package:lovelivemusicplayer/eventbus/db_init.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/pages/app/view.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_mine.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/error_log.dart';
import 'package:lovelivemusicplayer/utils/sentry_util.dart';

void main() async {
  runZonedGuarded(
    () async {
      // 初始化Sentry监控
      await SentryUtil.getInstance().init();
      WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      // 启动屏开启
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      AppUtils.disableWebDebugger();

      // 必须优先初始化
      await JustAudioBackground.init(
        androidNotificationChannelId:
            'com.zhushenwudi.lovelivemusicplayer.channel.audio',
        androidNotificationChannelName: 'lovelive audio playback',
        androidNotificationIcon: 'drawable/foreground',
        fastForwardInterval: const Duration(seconds: 5),
        rewindInterval: const Duration(seconds: 5),
      );

      eventBus.on<DbInit>().listen((event) async {
        runApp(const AppPage());
      });

      eventBus.on<CloseOpen>().listen((event) async {
        // 初始化结束后，将启动屏关闭
        FlutterNativeSplash.remove();
        if (Platform.isIOS) {
          Future.delayed(const Duration(milliseconds: 300), () async {
            // 在Carplay的init函数中初始化CarplayMine会导致程序卡死，提前初始化
            await CarplayMine.getInstance();
            Carplay.init();
          });
        }
      });

      // 初始化服务
      Get.put<GlobalLogic>(GlobalLogic(), permanent: true);
      await GlobalLogic.to.initServices();

      FlutterError.onError = (FlutterErrorDetails details) {
        // 获取 widget build 过程中出现的异常错误
        FlutterErrorReport.reportErrorAndLog(details);
      };

      AppUtils.hideStateBarAndNavigationBar();

      const platform = MethodChannel('llmp');
      platform.setMethodCallHandler((call) async {
        if (call.method == 'handleSchemeRequest') {
          if (call.arguments != null) {
            AppUtils.handleShare(call.arguments['url']);
          }
        }
      });

      // 发送打开app埋点
      SentryUtil.getInstance().upOpenApp();
    },
    (error, stackTrace) {
      // 没被catch的异常
      FlutterErrorReport.reportErrorAndLog(
          FlutterErrorReport.makeDetails(error, stackTrace));
    },
  );
}
