import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_theme.dart';
import 'package:lovelivemusicplayer/i10n/translation.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/http_server.dart';
import 'package:sharesdk_plugin/sharesdk_interface.dart';
import 'package:sharesdk_plugin/sharesdk_register.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 100;
    ShareSDKRegister register = ShareSDKRegister();
    register.setupQQ(Const.qqKey, Const.qqSecret);
    SharesdkPlugin.regist(register);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(Const.uiWidth, Const.uiHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            enableLog: kDebugMode,
            defaultTransition: Transition.rightToLeftWithFade,
            theme: GlobalLogic.to.isDark ? darkTheme : lightTheme,
            themeMode: ThemeMode.light,
            darkTheme: darkTheme,
            initialRoute: GlobalLogic.to.hasAIPic
                ? Routes.routeSplash
                : Routes.routeInitial,
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
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: widget!);
            }));
      },
    );
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (locales != null) {
      Get.updateLocale(locales.first);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:

        /// 进入前台时，恢复进入后台前列表的位置
        final controllerSize = HomeController.scrollControllers.length;
        if (controllerSize <= 0) {
          return;
        }
        for (var i = 0; i <= controllerSize - 1; i++) {
          final controller = HomeController.scrollControllers[i];
          final controllerOffset = HomeController.scrollOffsets[i];
          HomeController.checkAndJump(controller, controllerOffset);
        }

        /// 重新对歌曲主色调取值渲染
        GlobalLogic.to.refreshIconColor();
        break;
      case AppLifecycleState.inactive:

        /// 进入后台 && 展开了player组件时 关闭滚动歌词
        if (GlobalLogic.mobileWeSlideController.isOpened) {
          eventBus.fire(PlayerClosableEvent(true));
        }
        MyHttpServer.stopServer();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dbInitSub?.cancel();
    closeOpenSub?.cancel();
    super.dispose();
  }
}
