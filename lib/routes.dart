import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/pages/data_sync/data_sync.dart';
import 'package:lovelivemusicplayer/pages/home/home_binding.dart';
import 'package:lovelivemusicplayer/pages/home/home_view.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_binding.dart';
import 'package:lovelivemusicplayer/pages/music_trans/music_transform.dart';
import 'package:lovelivemusicplayer/pages/scan/scanner.dart';

class Routes {
  static const String routeInitial = "/";
  static const String routeHome = "/home";
  static const String routeScan = "/scan";
  static const String routeTransform = "/transform";
  static const String routeDataSync = "/data_sync";
  static const String routeAlbumDetails = "/album_details";
  static const String routeSingerDetails = "/singer_details";
  static const String routeMenuDetails = "/menu_details";
  static const String routeLogger = "/logger";

  static List<GetPage> getRoutes() {
    return [
      GetPage(
          name: Routes.routeInitial,
          page: () => const HomeView(),
          bindings: [HomeBinding(), NestedBinding()]),
      GetPage(name: Routes.routeScan, page: () => const Scanner()),
      GetPage(name: Routes.routeTransform, page: () => const MusicTransform()),
      GetPage(name: Routes.routeDataSync, page: () => const DataSync()),
      GetPage(name: Routes.routeLogger, page: () => const LogConsole()),
    ];
  }
}
