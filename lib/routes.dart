import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/album_details/view.dart';
import 'package:lovelivemusicplayer/pages/data_sync/data_sync.dart';
import 'package:lovelivemusicplayer/pages/home/home_binding.dart';
import 'package:lovelivemusicplayer/pages/home/home_view.dart';
import 'package:lovelivemusicplayer/pages/menu_details/view.dart';
import 'package:lovelivemusicplayer/pages/music_trans/music_transform.dart';
import 'package:lovelivemusicplayer/pages/scan/scanner.dart';
import 'package:lovelivemusicplayer/pages/singer_details/view.dart';

class Routes {
  static const String routeInitial = "/";
  static const String routeScan = "/scan";
  static const String routeTransform = "/transform";
  static const String routeDataSync = "/data_sync";
  static const String routeAlbumDetails = "/album_details";
  static const String routeSingerDetails = "/singer_details";
  static const String routeMenuDetails = "/menu_details";

  static List<GetPage> getRoutes() {
    return [
      GetPage(
          name: Routes.routeInitial,
          page: () => HomeView(),
          binding: HomeBinding()),
      GetPage(
          name: Routes.routeAlbumDetails, page: () => const AlbumDetailsPage()),
      GetPage(
          name: Routes.routeSingerDetails,
          page: () => const SingerDetailsPage()),
      GetPage(
          name: Routes.routeMenuDetails, page: () => const MenuDetailsPage()),
      GetPage(name: Routes.routeScan, page: () => const Scanner()),
      GetPage(name: Routes.routeTransform, page: () => MusicTransform()),
      GetPage(name: Routes.routeDataSync, page: () => const DataSync()),
    ];
  }
}
