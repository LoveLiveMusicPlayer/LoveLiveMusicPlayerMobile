import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/eventbus/start_event.dart';
import 'package:lovelivemusicplayer/global/global_binding.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sharesdk_plugin/sharesdk_plugin.dart';
import 'package:uni_links/uni_links.dart';

import 'global/const.dart';
import 'global/global_theme.dart';
import 'i10n/translation.dart';
import 'models/InitConfig.dart';
import 'network/http_request.dart';
import 'routes.dart';
import 'utils/sd_utils.dart';
import 'utils/sp_util.dart';

var isDark = false;
var appVersion = "1.0.0";
var hasAIPic = false;
var enableBG = false;
var needRemoveCover = true;
final splashList = <String>[];

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
  if (kReleaseMode) {
    void reportErrorAndLog(FlutterErrorDetails details) {
      if (details
          .exceptionAsString()
          .contains("ScrollController not attached to any scroll views")) {
        return;
      }
      final errorMsg = {
        "exception": details.exceptionAsString(),
        "stackTrace": details.stack.toString(),
      };
      Log4f.e(msg: "$errorMsg", writeFile: true);
    }

    FlutterErrorDetails makeDetails(Object error, StackTrace stackTrace) {
      // 构建错误信息
      return FlutterErrorDetails(stack: stackTrace, exception: error);
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      // 获取 widget build 过程中出现的异常错误
      reportErrorAndLog(details);
    };

    runZonedGuarded(
          () => runApp(Phoenix(child: const MyApp())),
          (error, stackTrace) {
        // 没被catch的异常
        reportErrorAndLog(makeDetails(error, stackTrace));
      },
    );
  } else {
    runApp(Phoenix(child: const MyApp()));
  }

  AppUtils.setStatusBar(isDark);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription? subscription;
  bool isInitialUriIsHandled = false;
  StreamSubscription? uriSub;

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (locales != null) {
      Get.updateLocale(locales.first);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    /// 进入后台 && 展开了player组件时 关闭滚动歌词
    if (state == AppLifecycleState.inactive &&
        GlobalLogic.mobileWeSlideController.isOpened) {
      eventBus.fire(PlayerClosableEvent(true));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    subscription = eventBus.on<StartEvent>().listen((event) {
      needRemoveCover = false;
      // 初始化结束后，将启动屏关闭
      FlutterNativeSplash.remove();
    });

    handleInitialUri();
    handleIncomingLinks();

    PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 100;

    ShareSDKRegister register = ShareSDKRegister();
    register.setupQQ("375f94ab8316c", "9cac7a0532d211eb04fcf6b25b197859");
    SharesdkPlugin.regist(register);
  }

  // 第一次打开
  Future<void> handleInitialUri() async {
    if (!isInitialUriIsHandled) {
      isInitialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (uri != null) {
          print('获取到的uri: $uri');
        }
      } catch (err) {
        Log4f.e(msg: err.toString());
      }
    }
  }

  // 程序打开时介入
  void handleIncomingLinks() {
    uriSub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print("获取到的uri2: $uri");
      }
    }, onError: (Object err) {
      Log4f.e(msg: err.toString());
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    uriSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
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
            enableLog: kDebugMode,
            defaultTransition: Transition.fade,
            theme: isDark ? darkTheme : lightTheme,
            themeMode: ThemeMode.light,
            darkTheme: darkTheme,
            initialRoute: hasAIPic ? Routes.routeSplash : Routes.routeInitial,
            getPages: Routes.getRoutes(),
            routingCallback: (Routing? route) {
              final name = route?.current;
              if (name != null) {
                AppUtils.uploadPageStart(name);
              }
            },
            locale: Translation.locale,
            fallbackLocale: Translation.fallbackLocale,
            translations: Translation(),
            builder: FlutterSmartDialog.init(builder: (context, widget) {
              return MediaQuery(
                  // 设置文字大小不随系统设置改变
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: widget!);
            }));
      },
    );
  }
}

/// 初始化服务等一系列耗时任务
initServices() async {
  appVersion = (await PackageInfo.fromPlatform()).version;
  await FlutterLogan.init(Const.aesKey, Const.iV, 1024 * 1024 * 10);
  Get.log = defaultLogWriterCallback;
  await GetStorage.init();
  SpUtil.getInstance();
  Network.getInstance();
  await SDUtils.init();
  PlayerBinding().dependencies();
  enableBG = await SpUtil.getBoolean(Const.spEnableBackgroundPhoto, false);
  hasAIPic = await SpUtil.getBoolean(Const.spAIPicture, true);
  await getOssUrl();
  SpUtil.put("prevPage", "");
}

/// 获取资源oss url，解析开屏图片数据
getOssUrl() async {
  try {
    final connection = await Connectivity().checkConnectivity();
    if (connection != ConnectivityResult.none) {
      final result = await Network.dio?.request<String>(Const.splashConfigUrl);
      if (result != null && result.data != null) {
        // 能够加载到开屏配置
        final config = initConfigFromJson(result.data!);
        Const.ossUrl = config.ossUrl;
        Const.splashUrl = config.ossUrl + config.splash.route;
        final forceMap = config.splash.forceChoose;

        // 先将全部图片放到列表中
        addAllSplashPhoto(config);

        if (forceMap == null) {
          return;
        }

        final endTime = forceMap["endTime"];
        if (endTime != null &&
            endTime < DateTime.now().millisecondsSinceEpoch) {
          return;
        }
        final forceId = forceMap["uid"];
        if (forceId == null) {
          return;
        }
        final forceBg = config.splash.bg
            .firstWhereOrNull((bg) => bg.uid == forceMap["uid"]);
        if (forceBg == null) {
          return;
        }
        final index = forceMap["index"];
        if (index == null || index < 0 || index > forceBg.size) {
          return;
        }

        // 需要强制开屏图，清空数组添加唯一一张
        splashList.clear();
        splashList.add(
            "${Const.splashUrl}${forceBg.singer}/bg_${forceBg.singer}_$index.png");
        return;
      }
    }
    // 手机无网络、开屏配置无法加载
    // 先延迟1s，避免数据库初始化未完成
    await Future.delayed(const Duration(seconds: 1));
    // 从数据库中加载全部开屏图地址
    final tempList = await DBLogic.to.splashDao.findAllSplashUrls();
    for (var splashItem in tempList) {
      // 过滤只保留仍然缓存中的图片
      final isExist = await AppUtils.checkUrlExist(splashItem.url);
      if (isExist) {
        splashList.add(splashItem.url);
      }
    }
  } catch (e) {
    Log4f.d(msg: e.toString());
  }
}

/// 将可用开屏界面地址全部添加到开屏图列表中
addAllSplashPhoto(InitConfig config) {
  for (var bg in config.splash.bg) {
    for (var index = 1; index <= bg.size; index++) {
      final photoUrl =
          "${Const.splashUrl}${bg.singer}/bg_${bg.singer}_$index.png";
      splashList.add(photoUrl);
    }
  }
}

/// GetX 日志重定向
void defaultLogWriterCallback(String value, {bool isError = false}) {
  if (isError) {
    Log4f.w(msg: value);
  }
}
