import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/start_event.dart';
import 'package:lovelivemusicplayer/global/global_binding.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'global/const.dart';
import 'global/global_theme.dart';
import 'i18n/translation.dart';
import 'network/http_request.dart';
import 'routes.dart';
import 'utils/sd_utils.dart';
import 'utils/sp_util.dart';

var isDark = false;

void main() async {
  // 启动屏开启
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 仅支持竖屏
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 初始化
  await initServices();
  isDark = await SpUtil.getBoolean(Const.spDark);
  await JustAudioBackground.init(
    androidNotificationChannelId:
        'com.zhushenwudi.lovelivemusicplayer.channel.audio',
    androidNotificationChannelName: 'lovelive audio playback',
    androidNotificationOngoing: true,
  );
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://dbb1e416963545c5893b40d85793e081@o1185358.ingest.sentry.io/6303906';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp()),
  );
  setStatusBar();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription = eventBus.on<StartEvent>().listen((event) {
      // 初始化结束后，将启动屏关闭
      FlutterNativeSplash.remove();
    });
    PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 100;
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 填入设计稿中设备的屏幕尺寸,单位dp
    return ScreenUtilInit(
      designSize: const Size(Const.uiWidth, Const.uiHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            enableLog: true,
            defaultTransition: Transition.fade,
            theme: isDark ? darkTheme : lightTheme,
            themeMode: ThemeMode.light,
            darkTheme: darkTheme,
            initialRoute: Routes.routeInitial,
            getPages: Routes.getRoutes(),
            locale: Translation.locale,
            fallbackLocale: Translation.fallbackLocale,
            translations: Translation(),
            builder: FlutterSmartDialog.init(builder: (context, widget) {
              return MediaQuery(

                  ///设置文字大小不随系统设置改变
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: widget!);
            }));
      },
    );
  }
}

/// 设置状态栏
setStatusBar() {
  SystemChrome.setSystemUIOverlayStyle(
      (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent));
}

/// 初始化服务等一系列耗时任务
initServices() async {
  await GetStorage.init();
  await SpUtil.getInstance();
  Network.getInstance();
  await SDUtils.init();
  PlayerBinding().dependencies();
  LogUtil.init(tag: "zhu", isDebug: kDebugMode);
  LogUtil.d('All services started...');
}
