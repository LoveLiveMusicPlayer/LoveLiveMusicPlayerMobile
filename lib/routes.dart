import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/daily/binding.dart';
import 'package:lovelivemusicplayer/pages/daily/view.dart';
import 'package:lovelivemusicplayer/pages/data_sync/view.dart';
import 'package:lovelivemusicplayer/pages/drive/binding.dart';
import 'package:lovelivemusicplayer/pages/drive/view.dart';
import 'package:lovelivemusicplayer/pages/home/home_binding.dart';
import 'package:lovelivemusicplayer/pages/home/home_view.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_binding.dart';
import 'package:lovelivemusicplayer/pages/moe_girl/moe_girl.dart';
import 'package:lovelivemusicplayer/pages/music_trans/view.dart';
import 'package:lovelivemusicplayer/pages/permission/binding.dart';
import 'package:lovelivemusicplayer/pages/permission/view.dart';
import 'package:lovelivemusicplayer/pages/scan/scanner.dart';
import 'package:lovelivemusicplayer/pages/splash/splash.dart';
import 'package:lovelivemusicplayer/pages/system/view.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:talker_flutter/talker_flutter.dart';

class Routes {
  static const String routeInitial = "/";
  static const String routeSplash = "/splash";
  static const String routeHome = "/home";
  static const String routePermission = "/permission";
  static const String routeScan = "/scan";
  static const String routeTransform = "/transform";
  static const String routeDataSync = "/data_sync";
  static const String routeAlbumDetails = "/album_details";
  static const String routeSingerDetails = "/singer_details";
  static const String routeMenuDetails = "/menu_details";
  static const String routeLogger = "/logger";
  static const String routeSystemSettings = "/system_settings";
  static const String routeDriveMode = "/drive_mode";
  static const String routeMoeGirl = "/moe_girl";
  static const String routeDaily = "/daily";

  static List<GetPage> getRoutes() {
    return [
      GetPage(name: Routes.routeSplash, page: () => const Splash()),
      GetPage(
          name: Routes.routeInitial,
          page: () => const HomeView(),
          bindings: [HomeBinding(), NestedBinding()]),
      GetPage(
          name: Routes.routePermission,
          page: () => const PermissionPage(),
          binding: PermissionBinding()),
      GetPage(name: Routes.routeScan, page: () => const Scanner()),
      GetPage(name: Routes.routeTransform, page: () => const MusicTransPage()),
      GetPage(name: Routes.routeDataSync, page: () => const DataSyncPage()),
      GetPage(
          name: Routes.routeLogger,
          page: () => TalkerScreen(talker: Log4f.getLogger())),
      GetPage(
          name: Routes.routeSystemSettings,
          page: () => const SystemSettingsPage()),
      GetPage(
          name: Routes.routeDriveMode,
          page: () => const DriveModePage(),
          binding: DriveModeBinding()),
      GetPage(name: Routes.routeMoeGirl, page: () => const MoeGirl()),
      GetPage(
          name: Routes.routeDaily,
          page: () => const DailyPage(),
          binding: DailyBinding()),
    ];
  }
}
