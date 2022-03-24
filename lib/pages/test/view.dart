import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_slide/we_slide.dart';
import '../player/bottom_bar.dart';
import '../player/home.dart';
import '../player/miniplayer.dart';
import '../player/player.dart';
import 'logic.dart';

class TestPage extends StatelessWidget {
  final logic = Get.put(TestLogic());
  final state = Get.find<TestLogic>().state;

  @override
  Widget build(BuildContext context) {
    final WeSlideController _controller = WeSlideController();
    const double _panelMinSize = 150;
    final double _panelMaxSize = MediaQuery.of(context).size.height;
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
        body: WeSlide(
      controller: _controller,
      panelMinSize: _panelMinSize.h,
      panelMaxSize: _panelMaxSize,
      overlayOpacity: 0.9,
      backgroundColor: colorTheme.background,
      overlay: true,
      isDismissible: true,
      body: Home(),
      panelHeader: MiniPlayer(
          onTap: _controller.show,
          onChangeMusic: (index, reason) => {
                LogUtil.e("选择了第$index首")
              }),
      panel: Player(onTap: _controller.hide),
      footer: Obx(() {
        return BottomBar(logic.currentIndex.value, onSelect: (index) {
          logic.currentIndex.value = index;
        });
      }),
      footerHeight: 84.h,
      blur: true,
      parallax: true,
      transformScale: true,
      blurSigma: 5.0,
    ));
  }
}
