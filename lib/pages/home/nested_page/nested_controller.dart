import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/pages/details/album_details/view.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/view.dart';
import 'package:lovelivemusicplayer/pages/details/singer_details/view.dart';
import 'package:lovelivemusicplayer/pages/home/page_view/home_page_view.dart';
import 'package:lovelivemusicplayer/routes.dart';

class NestedController extends GetxController {
  static NestedController get to => Get.find();

  late Album album;
  late Artist artist;
  late int menuId;
  String currentIndex = Routes.routeHome;

  // 是否能够延时隐藏bottomBar
  bool canHideFooterController = true;

  final pages = <String>[
    Routes.routeHome,
    Routes.routeAlbumDetails,
    Routes.routeSingerDetails,
    Routes.routeMenuDetails
  ];

  goBack() {
    GlobalLogic.mobileWeSlideFooterController.show();
    currentIndex = Routes.routeHome;
    GlobalLogic.to.needHomeSafeArea.value = false;
    Get.back(id: 1);
  }

  Route? onGenerateRoute(RouteSettings settings) {
    if (settings.name == Routes.routeHome) {
      currentIndex = Routes.routeHome;
      return GetPageRoute(settings: settings, page: () => const HomePageView());
    } else if (settings.name == Routes.routeAlbumDetails) {
      currentIndex = Routes.routeAlbumDetails;
      GlobalLogic.mobileWeSlideFooterController.hide();
      album = settings.arguments as Album;
      return GetPageRoute(
        settings: settings,
        page: () => const AlbumDetailsPage(),
        transition: Transition.topLevel,
      );
    } else if (settings.name == Routes.routeSingerDetails) {
      currentIndex = Routes.routeSingerDetails;
      GlobalLogic.mobileWeSlideFooterController.hide();
      artist = settings.arguments as Artist;
      return GetPageRoute(
        settings: settings,
        page: () => const SingerDetailsPage(),
        transition: Transition.rightToLeftWithFade,
      );
    } else if (settings.name == Routes.routeMenuDetails) {
      currentIndex = Routes.routeMenuDetails;
      GlobalLogic.mobileWeSlideFooterController.hide();
      menuId = settings.arguments as int;
      return GetPageRoute(
        settings: settings,
        page: () => const MenuDetailsPage(),
        transition: Transition.fadeIn,
      );
    }

    return null;
  }
}
