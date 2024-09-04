import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/pages/details/album_details/binding.dart';
import 'package:lovelivemusicplayer/pages/details/album_details/view.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/binding.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/view.dart';
import 'package:lovelivemusicplayer/pages/details/singer_details/binding.dart';
import 'package:lovelivemusicplayer/pages/details/singer_details/view.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/page_view/home_page_view.dart';
import 'package:lovelivemusicplayer/pages/system/binding.dart';
import 'package:lovelivemusicplayer/pages/system/view.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class NestedController extends GetxController {
  static NestedController get to => Get.find();

  late Album album;
  late Artist artist;
  late Menu menu;
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

  get isHomePage => routeList.last == Routes.routeHome;

  addNav(String route) {
    routeList.add(route);
    currentIndex = route;
    if (route != Routes.routeHome) {
      Timer(const Duration(milliseconds: 500), () {
        GlobalLogic.to.needHomeSafeArea.value = true;
        GlobalLogic.mobileWeSlideFooterController.hide();
      });
    }
  }

  reduceNav() {
    Timer(const Duration(milliseconds: 500), () {
      if (currentIndex == Routes.routeHome) {
        GlobalLogic.mobileWeSlideFooterController.show();
      }
      GlobalLogic.to.needHomeSafeArea.value = !isHomePage;
    });
  }

  goBack({bool fromBtnBack = false}) {
    routeList.removeLast();
    currentIndex = routeList.last;
    if (fromBtnBack) {
      Get.back(id: 1);
    }
    reduceNav();
  }

  Route? onGenerateRoute(RouteSettings settings) {
    if (settings.name == Routes.routeHome) {
      addNav(Routes.routeHome);
      return GetPageRoute(
          settings: settings,
          page: () => ScrollsToTop(
              onScrollsToTop: (_) async => scrollViewToTop(),
              child: const HomePageView()));
    } else if (settings.name == Routes.routeAlbumDetails) {
      addNav(Routes.routeAlbumDetails);
      album = settings.arguments as Album;
      return GetPageRoute(
          routeName: "album_details",
          settings: settings,
          page: () => const AlbumDetailsPage(),
          binding: AlbumDetailBinding());
    } else if (settings.name == Routes.routeSingerDetails) {
      addNav(Routes.routeSingerDetails);
      artist = settings.arguments as Artist;
      return GetPageRoute(
          routeName: "singer_details",
          settings: settings,
          page: () => const SingerDetailsPage(),
          binding: SingerDetailBinding());
    } else if (settings.name == Routes.routeMenuDetails) {
      addNav(Routes.routeMenuDetails);
      menu = settings.arguments as Menu;
      return GetPageRoute(
          routeName: "menu_details",
          settings: settings,
          page: () => const MenuDetailsPage(),
          binding: MenuDetailBinding());
    } else if (settings.name == Routes.routeSystemSettings) {
      addNav(Routes.routeSystemSettings);
      return GetPageRoute(
          routeName: "setting",
          settings: settings,
          page: () => const SystemSettingsPage(),
          binding: SystemSettingBinding());
    }
    return null;
  }

  void scrollViewToTop() {
    try {
      DBLogic.to.scrollToTop(
          HomeController
              .scrollControllers[HomeController.to.state.currentIndex.value],
          withAnimation: true);
    } catch (_) {}
  }
}
