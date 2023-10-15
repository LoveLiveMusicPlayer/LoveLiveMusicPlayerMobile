import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class SwipeImageCarousel extends StatefulWidget {
  final Music currentPlay;

  const SwipeImageCarousel({super.key, required this.currentPlay});

  @override
  _SwipeImageCarouselState createState() => _SwipeImageCarouselState();
}

class _SwipeImageCarouselState extends State<SwipeImageCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;

  int _currentPage = 0;
  int fingerCount = 0;
  double pageViewOffset = 0.0;
  double centerViewOffset = 0.0;

  @override
  void initState() {
    _currentPage = GlobalLogic.to.musicList.indexWhere((element) => element.musicId == PlayerLogic.to.playingMusic.value.musicId);
    _pageController =
        PageController(initialPage: _currentPage, viewportFraction: 0.65);
    _pageController.addListener(_handlePageController);

    super.initState();
  }

  void _handlePageController() {
    // 在这里处理PageController的位置变化
    final currentOffset = _pageController.offset;
    final viewportFraction = _pageController.viewportFraction;
    final ratio = currentOffset / (viewportFraction * Get.width);
    final currentIndex = ratio.round();

    setState(() {
      centerViewOffset = (currentOffset % (viewportFraction * Get.width)) /
          (viewportFraction * Get.width) *
          40;
    });
    // Log4f.d(msg: "currentOffset: $currentOffset  screen: ${viewportFraction * Get.width}");

    if (currentIndex < 0 || currentIndex >= GlobalLogic.to.musicList.length) {
      return;
    }
    if (_currentPage != currentIndex) {
      Log4f.d(msg: "当前选中: $currentIndex");
      // 如果位置发生变化，执行你想要的操作
      // ...

      // 更新当前页面索引
      // 不调用setState，避免触发onPageChanged回调
      _currentPage = currentIndex;
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageController);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (PointerDownEvent event) {
          if (fingerCount > 0 && fingerCount < event.pointer) {
            return;
          }
          setState(() {
            fingerCount = event.pointer;
          });
        },
        onPointerUp: (PointerUpEvent event) {
          if (fingerCount != event.pointer) {
            return;
          }
          setState(() {
            fingerCount = 0;
          });

          Log4f.d(msg: "播放歌曲");
        },
        onPointerMove: (PointerMoveEvent event) {
          if (fingerCount != event.pointer) {
            return;
          }
          final dragDistance = event.delta.dx;
          pageViewOffset = _pageController.offset - dragDistance;
          _pageController.jumpTo(pageViewOffset);
        },
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemCount: GlobalLogic.to.musicList.length,
          itemBuilder: (context, index) {
            int currentIndex = _currentPage.round();
            double scaleFactor = 0.75;
            double value = 1.0 - (index - currentIndex).abs().toDouble();

            if (value < 0.0) {
              value = 0.0;
            }

            double scale = (1 - value) * scaleFactor + value;
            bool isCenter = index - currentIndex == 0;

            Log4f.d(msg: "$centerViewOffset");

            final imagePath =
                SDUtils.getImgPathFromMusic(GlobalLogic.to.musicList[index]);
            Image imageView;
            if (imagePath == null) {
              imageView = Image.asset(Assets.logoLogo, fit: BoxFit.cover, width: 240.r, height: 240.r);
            } else {
              imageView = Image.file(File(imagePath), fit: BoxFit.cover, width: 240.r, height: 240.r);
            }

            return Center(
                child: Transform.scale(
              scale: scale,
              child: Transform.translate(
                offset: Offset(0, isCenter ? -centerViewOffset : 0),
                // 乘以动画值
                child: ClipOval(
                  child: imageView,
                ),
              ),
            ));
          },
        ));
  }
}
