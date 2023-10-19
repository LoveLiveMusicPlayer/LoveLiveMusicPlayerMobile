import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/another_page_view/another_transformer_page_view.dart';

class SwipeImageCarousel extends StatefulWidget {
  const SwipeImageCarousel({super.key});

  @override
  SwipeImageCarouselState createState() => SwipeImageCarouselState();
}

class SwipeImageCarouselState extends State<SwipeImageCarousel>
    with AutomaticKeepAliveClientMixin {
  late TransformerPageController _pageController;
  late Worker playingMusicListener;

  // 切歌过程控制是否可以滚动
  bool canScroll = true;

  // 当前PageView滚动的页位置
  int _currentPage = 0;

  // 记录的点击手指的数量
  int fingerCount = 0;

  // 按下手指记录的横坐标位置
  double downDx = 0;

  @override
  void initState() {
    // 初始化计算当前显示列表的page位置
    _currentPage = PlayerLogic.to.mPlayList.indexWhere((element) =>
        element.musicId == PlayerLogic.to.playingMusic.value.musicId);
    _pageController = TransformerPageController(
        initialPage: _currentPage,
        viewportFraction: 0.62,
        itemCount: PlayerLogic.to.mPlayList.length);

    final playerLogic = Get.find<PlayerLogic>();
    // 注册播放曲目监听
    playingMusicListener = ever(playerLogic.playingMusic, (Music music) {
      // 将PageView同步滚动到当前播放的索引
      _currentPage = playerLogic.mPlayer.currentIndex ?? 0;
      _animateTo(_currentPage);
    });
    super.initState();
  }

  /// 计算当前PageView的索引值
  int _calcPageController() {
    final currentOffset = _pageController.offset;
    final viewportFraction = _pageController.viewportFraction;
    final ratio = currentOffset / (viewportFraction * Get.width);
    final currentIndex = ratio.round();

    if (currentIndex < 0 || currentIndex >= PlayerLogic.to.mPlayList.length) {
      return _currentPage;
    }
    if (_currentPage != currentIndex) {
      return currentIndex;
    }
    return _currentPage;
  }

  Future<void> _animateTo(int page) async {
    await _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  /// 刷新播放器列表
  Future<void> resetMusic(int appendPage) async {
    List<String> idList = [];
    for (var element in PlayerLogic.to.mPlayList) {
      idList.add(element.musicId);
    }
    var musicList = await DBLogic.to.findMusicByMusicIds(idList);
    final currentPage = _currentPage + appendPage;
    await PlayerLogic.to
        .playMusic(musicList, mIndex: currentPage, showDialog: false);
  }

  @override
  void dispose() {
    playingMusicListener.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (!canScroll) {
          // 事件处理中，过滤
          return;
        }
        if (fingerCount > 0 && fingerCount < event.pointer) {
          // 禁用多指操控
          return;
        }
        // 记录点击横坐标
        downDx = event.position.dx;
        // 记录手指数量
        fingerCount = event.pointer;
      },
      onPointerUp: (PointerUpEvent event) async {
        if (!canScroll) {
          // 事件处理中，过滤
          return;
        }
        if (fingerCount != event.pointer) {
          // 禁用多指操控
          return;
        }
        // 事件开始处理
        canScroll = false;
        fingerCount = 0;

        // 计算横坐标偏移量
        final dt = event.position.dx - downDx;
        // 计算是否需要跳转PageView
        final needJump = dt.abs() > (Get.width / 3);

        if (needJump) {
          // 由于播放器机制，需要单独适配单曲循环的情况
          final isLoopOne = PlayerLogic.to.mPlayer.loopMode == LoopMode.one;
          if (dt > 0) {
            if (isLoopOne) {
              // 上一曲 && 单曲循环模式
              await resetMusic(-1);
            } else {
              // 上一曲 && (列表循环 || 随机播放)
              await PlayerLogic.to.playPrev();
            }
          } else {
            if (isLoopOne) {
              // 下一曲 && 单曲循环模式
              await resetMusic(1);
            } else {
              // 下一曲 && (列表循环 || 随机播放)
              await PlayerLogic.to.playNext();
            }
          }
          // 重新计算当前PageView的页位置
          _currentPage = _calcPageController();
        }
        // 使得具备类似模拟吸边效果的动画 then 事件结束处理
        _animateTo(_currentPage).then((value) => canScroll = true);
      },
      onPointerMove: (PointerMoveEvent event) {
        if (fingerCount != event.pointer) {
          // 禁用多指操控
          return;
        }
        // 计算Gesture的横坐标偏移
        final dragDistance = event.delta.dx;
        final pageViewOffset = _pageController.offset - dragDistance;
        // 将偏移同步到PageView上
        _pageController.jumpTo(pageViewOffset);
      },
      child: TransformerPageView(
        pageController: _pageController,
        pageSnapping: false,
        physics: const NeverScrollableScrollPhysics(),
        transformer: ScaleAndFadeTransformer(),
        viewportFraction: 0.62,
        itemCount: PlayerLogic.to.mPlayList.length,
        itemBuilder: (context, index) {
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
                  child: ClipOval(
                    child: imageView,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double _scale;
  final double _fade;

  ScaleAndFadeTransformer({double fade = 0.3, double scale = 0.5})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = info.position!;

    final scaleFactor = (1 - position.abs()) * (1 - _scale);
    final fadeFactor = (1 - position.abs()) * (1 - _fade);
    final opacity = _fade + fadeFactor;
    final scale = _scale + scaleFactor;
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, scale * -40),
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}
