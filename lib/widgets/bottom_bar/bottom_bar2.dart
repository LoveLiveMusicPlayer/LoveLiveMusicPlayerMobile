import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar/bottom_bar_base.dart';

class BottomBar2 extends BottomBar {
  const BottomBar2({super.key}) : super(2);

  @override
  List<BottomNavigationBarItem> renderBottomNavigationBarItemList(int cIndex) {
    return [
      bottomBar(Assets.tabTabLove, cIndex == 0, 'iLove'.tr),
      bottomBar(Assets.tabTabPlaylist, cIndex == 1, 'songMenu'.tr),
      bottomBar(Assets.tabTabRecently, cIndex == 2, 'history'.tr)
    ];
  }
}
