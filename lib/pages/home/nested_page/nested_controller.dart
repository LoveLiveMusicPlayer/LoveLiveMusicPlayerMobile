import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/pages/details/album_details/view.dart';
import 'package:lovelivemusicplayer/pages/details/binding.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/view.dart';
import 'package:lovelivemusicplayer/pages/details/singer_details/view.dart';
import 'package:lovelivemusicplayer/pages/home/page_view/home_page_view.dart';
import 'package:lovelivemusicplayer/pages/system/system_settings.dart';
import 'package:lovelivemusicplayer/routes.dart';

class NestedController extends GetxController {
  static NestedController get to => Get.find();

  late Album album;
  late Artist artist;
  late int menuId;
  String currentIndex = Routes.routeHome;
  final routeList = <String>[];
  bool fromGestureBack = true;

  final pages = <String>[
    Routes.routeHome,
    Routes.routeAlbumDetails,
    Routes.routeSingerDetails,
    Routes.routeMenuDetails,
    Routes.routeSystemSettings
  ];

  addNav(String route) {
    routeList.add(route);
    currentIndex = route;
    if (route != Routes.routeHome) {
      GlobalLogic.to.needHomeSafeArea.value = true;
      GlobalLogic.mobileWeSlideFooterController.hide();
    }
  }

  reduceNav() {
    if (currentIndex == Routes.routeHome) {
      GlobalLogic.mobileWeSlideFooterController.show();
    }
    GlobalLogic.to.needHomeSafeArea.value = routeList.last != Routes.routeHome;
  }

  goBack({bool fromBtnBack = false}) {
    routeList.removeLast();
    currentIndex = routeList.last;
    if (fromBtnBack) {
      Get.back(id: 1);
    }
    Timer(const Duration(milliseconds: 500), () {
      reduceNav();
    });
  }

  Route? onGenerateRoute(RouteSettings settings) {
    if (settings.name == Routes.routeHome) {
      addNav(Routes.routeHome);
      return GetPageRoute(settings: settings, page: () => const HomePageView());
    } else if (settings.name == Routes.routeAlbumDetails) {
      addNav(Routes.routeAlbumDetails);
      album = settings.arguments as Album;
      return GetPageRoute(
          routeName: "album_details",
          settings: settings,
          page: () => const AlbumDetailsPage(),
          binding: DetailBinding());
    } else if (settings.name == Routes.routeSingerDetails) {
      addNav(Routes.routeSingerDetails);
      artist = settings.arguments as Artist;
      return GetPageRoute(
          routeName: "singer_details",
          settings: settings,
          page: () => const SingerDetailsPage(),
          binding: DetailBinding());
    } else if (settings.name == Routes.routeMenuDetails) {
      addNav(Routes.routeMenuDetails);
      menuId = settings.arguments as int;
      return GetPageRoute(
          routeName: "menu_details",
          settings: settings,
          page: () => const MenuDetailsPage(),
          binding: DetailBinding());
    } else if (settings.name == Routes.routeSystemSettings) {
      addNav(Routes.routeSystemSettings);
      return GetPageRoute(
          settings: settings, page: () => const SystemSettings());
    }
    return null;
  }
}
