import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/artist.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_menu.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/log.dart';

class PageViewLogic extends GetxController {
  final pageController = PageController();

  var canScroll = true.obs;

  static PageViewLogic get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    for (var i = 0; i <= HomeController.scrollControllers.length - 1; i++) {
      final controller = HomeController.scrollControllers[i];
      controller.addListener(() {
        HomeController.scrollOffsets[i] = controller.offset;
      });
    }
  }

  showMoreDialog(dynamic model) {
    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        builder: (context) {
          if (model is Music) {
            return DialogMoreWithMusic(music: model);
          } else if (model is Menu) {
            return DialogMoreWithMenu(menu: model);
          }
          return Container();
        });
  }

  play(List<Music> musicList, int index) {
    PlayerLogic.to.playMusic(musicList, mIndex: index);
  }

  onItemTap(dynamic model) {
    if (model is Album) {
      Get.toNamed(Routes.routeAlbumDetails, arguments: model, id: 1);
    } else if (model is Artist) {
      Get.toNamed(Routes.routeSingerDetails, arguments: model, id: 1);
    } else if (model is Menu) {
      Get.toNamed(Routes.routeMenuDetails, arguments: model.id, id: 1);
    }
  }
}
