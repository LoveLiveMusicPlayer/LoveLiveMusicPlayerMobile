import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class SwipeImageCarousel extends StatefulWidget {
  const SwipeImageCarousel({super.key});

  @override
  SwipeImageCarouselState createState() => SwipeImageCarouselState();
}

class SwipeImageCarouselState extends State<SwipeImageCarousel> {
  late PageController _pageController;
  late Worker playingMusicListener;

  // 切歌过程控制是否可以滚动
  bool canScroll = true;
  int _currentPage = 0;
  int fingerCount = 0;
  double pageViewOffset = 0.0;
  double centerViewOffset = 0.0;

  @override
  void initState() {
    refreshCurrent(true);
    _pageController =
        PageController(initialPage: _currentPage, viewportFraction: 0.65);
    _pageController.addListener(_handlePageController);

    final playerLogic = Get.find<PlayerLogic>();
    playingMusicListener = ever(playerLogic.playingMusic, (Music music) {
      refreshCurrent(false);
    });
    super.initState();
  }

  refreshCurrent(bool isInit) {
    _currentPage = PlayerLogic.to.mPlayList.indexWhere((element) =>
        element.musicId == PlayerLogic.to.playingMusic.value.musicId);
    if (!isInit) {
      _pageController.jumpToPage(_currentPage);
    }
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

    if (currentIndex < 0 || currentIndex >= PlayerLogic.to.mPlayList.length) {
      return;
    }
    if (_currentPage != currentIndex) {
      Log4f.d(msg: "当前选中: $currentIndex");
      // 更新当前页面索引
      // 不调用setState，避免触发onPageChanged回调
      _currentPage = currentIndex;
    }
  }

  @override
  void dispose() {
    playingMusicListener.dispose();
    _pageController.removeListener(_handlePageController);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (!canScroll) {
          return;
        }
        if (fingerCount > 0 && fingerCount < event.pointer) {
          return;
        }
        fingerCount = event.pointer;
      },
      onPointerUp: (PointerUpEvent event) async {
        if (!canScroll) {
          return;
        }
        if (fingerCount != event.pointer) {
          return;
        }
        fingerCount = 0;
        final page = _currentPage;
        if (PlayerLogic.to.mPlayList[page].musicId == PlayerLogic.to.playingMusic.value.musicId) {
          return;
        }

        canScroll = false;
        List<String> idList = [];
        for (var element in PlayerLogic.to.mPlayList) {
          idList.add(element.musicId);
        }
        var musicList = await DBLogic.to.findMusicByMusicIds(idList);
        // 延时500ms让动画流畅收尾
        await Future.delayed(const Duration(milliseconds: 500));
        await PlayerLogic.to.playMusic(musicList, mIndex: page, showDialog: false);
        // 延时2s防止切换过快
        await Future.delayed(const Duration(seconds: 2));
        canScroll = true;
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
        itemCount: PlayerLogic.to.mPlayList.length,
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

          return FutureBuilder<String?>(
            future: SDUtils.getImgPathFromMusicId(
                PlayerLogic.to.mPlayList[index].musicId),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                String? imagePath = snapshot.data;

                Image imageView;
                if (imagePath == null) {
                  imageView = Image.asset(
                    Assets.logoLogo,
                    fit: BoxFit.cover,
                    width: 240.r,
                    height: 240.r,
                  );
                } else {
                  imageView = Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: 240.r,
                    height: 240.r,
                  );
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
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
