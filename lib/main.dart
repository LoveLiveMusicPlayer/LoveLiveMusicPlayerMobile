import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/eventbus/close_open.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/global/global_binding.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_mine.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/completer_ext.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sharesdk_plugin/sharesdk_plugin.dart';

import 'global/const.dart';
import 'global/global_player.dart';
import 'global/global_theme.dart';
import 'i10n/translation.dart';
import 'models/init_config.dart';
import 'network/http_request.dart';
import 'routes.dart';
import 'utils/sd_utils.dart';
import 'utils/sp_util.dart';

// 是否需要清理数据
const needClearApp = false;
// 当前环境
const env = "pre";

// 是否是暗黑主题
var isDark = false;
// APP版本号
var appVersion = "1.0.0";
// 是否有AI开屏
var hasAIPic = false;
// 是否允许显示背景图片
var enableBG = false;
// 传输协议版本号
const transVer = 1;
// 开屏图片列表
final splashList = <String>[];
// 是否可以使用SmartDialog
var isCanUseSmartDialog = false;
// 是否初始化好SplashDao
var isInitSplashDao = false;

InAppLocalhostServer? localhostServer;

late RemoteHttp remoteHttp;

late Carplay carplay;

void main() async {
  Future<void> reportErrorAndLog(FlutterErrorDetails details) async {
    final errorStr = details.exceptionAsString();
    if (errorStr
        .contains("ScrollController not attached to any scroll views")) {
      return;
    }
    final errorMsg = {
      "exception": errorStr,
      "stackTrace": details.stack.toString(),
    };
    if (kDebugMode) {
      Log4f.i(msg: "$errorMsg");
    }
  }

  FlutterErrorDetails makeDetails(Object error, StackTrace stackTrace) {
    // 构建错误信息
    return FlutterErrorDetails(stack: stackTrace, exception: error);
  }

  runZonedGuarded(
    () async {
      // 启动屏开启
      WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      // 仅支持竖屏
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      // 禁用 Android WebView Inspect
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await InAppWebViewController.setWebContentsDebuggingEnabled(false);
      }

      // 必须优先初始化
      await JustAudioBackground.init(
        androidNotificationChannelId:
            'com.zhushenwudi.lovelivemusicplayer.channel.audio',
        androidNotificationChannelName: 'lovelive audio playback',
        androidNotificationOngoing: true,
      );

      // 初始化
      await initServices();
      isDark = await SpUtil.getBoolean(Const.spDark);

      FlutterError.onError = (FlutterErrorDetails details) {
        // 获取 widget build 过程中出现的异常错误
        reportErrorAndLog(details);
      };

      runApp(const MyApp());

      AppUtils.setStatusBar(isDark);

      const platform = MethodChannel('llmp');
      platform.setMethodCallHandler((call) async {
        if (call.method == 'handleSchemeRequest') {
          if (call.arguments != null) {
            AppUtils.handleShare(call.arguments['url']);
          }
        }
      });
    },
    (error, stackTrace) {
      // 没被catch的异常
      reportErrorAndLog(makeDetails(error, stackTrace));
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription? subscription;

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
    if (state == AppLifecycleState.inactive) {
      if (GlobalLogic.mobileWeSlideController.isOpened) {
        eventBus.fire(PlayerClosableEvent(true));
      }
      stopServer();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    subscription = eventBus.on<CloseOpen>().listen((event) async {
      // 在Carplay的init函数中初始化CarplayMine会导致程序卡死，提前初始化
      await CarplayMine.getInstance();
      Carplay.init();
      // 初始化结束后，将启动屏关闭
      FlutterNativeSplash.remove();
    });

    PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 100;

    ShareSDKRegister register = ShareSDKRegister();
    register.setupQQ("375f94ab8316c", "9cac7a0532d211eb04fcf6b25b197859");
    SharesdkPlugin.regist(register);
  }

  @override
  void dispose() {
    subscription?.cancel();
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
            defaultTransition: Transition.rightToLeftWithFade,
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
  remoteHttp = RemoteHttp(await SpUtil.getBoolean(Const.spEnableHttp, false),
      await SpUtil.getString(Const.spHttpUrl, ""));
  enableBG = await SpUtil.getBoolean(Const.spEnableBackgroundPhoto, false);
  hasAIPic = await SpUtil.getBoolean(Const.spAIPicture, true);
  PlayerBinding().dependencies();
  if (hasAIPic) await getOssUrl();
  SpUtil.put(Const.spPrevPage, "");
}

startServer() {
  localhostServer ??= InAppLocalhostServer(documentRoot: 'assets/tachie');
  if (true == localhostServer?.isRunning()) {
    return;
  }
  localhostServer?.start();
}

stopServer() {
  if (localhostServer == null) {
    return;
  }
  if (true == localhostServer?.isRunning()) {
    localhostServer?.close();
  }
  localhostServer = null;
}

/// 获取资源oss url，解析开屏图片数据
getOssUrl() async {
  try {
    final connection = await Connectivity().checkConnectivity();
    if (connection != ConnectivityResult.none) {
      final result = await Network.getSync(Const.splashConfigUrl);
      if (result is Map<String, dynamic>) {
        // 能够加载到开屏配置
        final config = initConfigFromJson(jsonEncode(result));
        Const.dataOssUrl = config.ossUrl;
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
    // 等待isInitSplashDao变化，避免数据库初始化未完成
    await CompleterExt.awaitFor<bool>((run) {
      var count = 0;
      // 定时300ms检测一次变化
      Timer.periodic(const Duration(milliseconds: 300), (timer) async {
        count++;
        if (isInitSplashDao) {
          // 从数据库中加载全部开屏图地址
          final tempList = await DBLogic.to.splashDao.findAllSplashUrls();
          for (var splashItem in tempList) {
            // 过滤只保留仍然缓存中的图片
            final isExist = await AppUtils.checkUrlExist(splashItem.url);
            if (isExist) {
              splashList.add(splashItem.url);
            }
          }
          timer.cancel();
          run(true);
        } else if (count >= 10) {
          // 轮询超过10次就强制停止
          timer.cancel();
          run(true);
        }
      });
    });
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
  if (isError && !value.contains("already removed")) {
    Log4f.i(msg: value);
  }
}

/// HTTP远端曲库实体类
class RemoteHttp {
  late ValueNotifier<bool> enableHttp;
  late ValueNotifier<String> httpUrl;

  RemoteHttp(bool enableHttp, String httpUrl) {
    this.enableHttp = ValueNotifier(enableHttp);
    this.httpUrl = ValueNotifier(httpUrl);
  }

  // 是否开启了远端HTTP服务
  bool isEnableHttp() {
    return enableHttp.value;
  }

  // 是否没有正确填写远端曲库URL
  bool noneHttpUrl() {
    return httpUrl.value.isEmpty || httpUrl.value == '/';
  }

  // 是否能够拼接完整URL路径
  bool canUseHttpUrl() {
    return isEnableHttp() && !noneHttpUrl();
  }

  setEnableHttp(bool newValue) async {
    enableHttp.value = newValue;
    await PlayerLogic.to.removeAllMusics();
    await SpUtil.put(Const.spEnableHttp, newValue);
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
  }

  setHttpUrl(String newValue) async {
    httpUrl.value = newValue;
    await SpUtil.put(Const.spHttpUrl, newValue);
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
  }
}
