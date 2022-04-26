import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/album_details/view.dart';
import 'package:lovelivemusicplayer/pages/home/home_binding.dart';
import 'package:lovelivemusicplayer/pages/home/home_view.dart';
import 'package:lovelivemusicplayer/pages/singer_details/view.dart';

class Routes {
  static const String routeInitial = "/";
  static const String routeScan = "/scan";
  static const String routeTransform = "/transform";
  static const String routeAlbumDetails = "/album_details";
  static const String routeSingerDetails = "/singer_details";

  static List<GetPage> getRoutes() {
    return [
      GetPage(name: Routes.routeInitial, page: () => HomeView(), binding: HomeBinding()),
      GetPage(name: Routes.routeAlbumDetails, page: () => AlbumDetailsPage()),
      GetPage(name: Routes.routeSingerDetails, page: () => SingerDetailsPage()),
    ];
  }
}