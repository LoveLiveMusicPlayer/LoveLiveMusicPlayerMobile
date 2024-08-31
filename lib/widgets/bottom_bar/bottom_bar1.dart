import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar/bottom_bar_base.dart';

class BottomBar1 extends BottomBar {
  const BottomBar1({super.key}) : super(1);

  @override
  List<BottomNavigationBarItem> renderBottomNavigationBarItemList(int cIndex) {
    return [
      bottomBar(Assets.tabTabMusic, cIndex == 0, 'music'.tr),
      bottomBar(Assets.tabTabAlbum, cIndex == 1, 'album'.tr),
      bottomBar(Assets.tabTabSinger, cIndex == 2, 'singer'.tr)
    ];
  }
}
