import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'routes.dart';
import 'package:flutter/services.dart';
import 'global/const.dart';
import 'i18n/translation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'network/http_request.dart';
import 'utils/sd_utils.dart';
import 'utils/sp_util.dart';

var isDark = false;

void main() async {
  // 启动屏开启
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 初始化
  await initServices();
  isDark = await SpUtil.getBoolean(Const.spDark);
  runApp(const MyApp());
  setStatusBar();

  await Future.delayed(const Duration(seconds: 2));

  // 启动屏关闭
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 填入设计稿中设备的屏幕尺寸,单位dp
    return ScreenUtilInit(
      designSize: const Size(Const.uiWidth, Const.uiHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: () {
        return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            enableLog: true,
            defaultTransition: Transition.fade,
            theme: isDark ? ThemeData.dark() : ThemeData.light(),
            initialRoute: Routes.routeInitial,
            getPages: Routes.getRoutes(),
            locale: Translation.locale,
            fallbackLocale: Translation.fallbackLocale,
            translations: Translation(),
            builder: FlutterSmartDialog.init());
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
  SDUtils.init();
  LogUtil.init(tag: "iLab", isDebug: kDebugMode);
  LogUtil.d('All services started...');
}