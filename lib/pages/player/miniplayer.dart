import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/carousel/carousel_slider.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:marquee_text/marquee_text.dart';

import '../../models/Music.dart';
import '../../modules/ext.dart';

class MiniPlayer extends StatefulWidget {
  MiniPlayer({Key? key, required this.onTap}) : super(key: key);
  final GestureTapCallback onTap;

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final scrollList = <Widget>[];

  CarouselController sliderController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Decoration? decoration;
      final music = PlayerLogic.to.playingMusic.value;
      if (music.uid == null ||
          music.coverPath == null ||
          music.coverPath!.isEmpty) {
        decoration = BoxDecoration(
          color: const Color(0xFFEBF3FE),
          borderRadius: BorderRadius.circular(34),
        );
      } else {
        decoration = BoxDecoration(
          image: DecorationImage(
              image: FileImage(SDUtils.getImgFile(music.coverPath ?? "")),
              fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(34),
        );
      }

      return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(34),
          ),
          child: Column(
            children: [
              Container(
                height: 60.h,
                margin: EdgeInsets.only(left: 16.w, right: 16.w),
                decoration: decoration,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: BackdropFilter(
                      //背景滤镜
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), //背景模糊化
                      child: body(),
                    )),
              ),
            ],
          ));
    });
  }

  Widget body() {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey.withOpacity(0.05),
      child: Row(
        children: [
          /// 迷你封面
          miniCover(),
          SizedBox(width: 6.w),

          /// 滚动歌名
          marqueeMusicName(),
          SizedBox(width: 10.w),

          /// 播放按钮
          Obx(() {
            return touchIconByAsset(
                path: PlayerLogic.to.isPlaying.value
                    ? "assets/player/play_pause.svg"
                    : "assets/player/play_play.svg",
                onTap: () => {PlayerLogic.to.togglePlay()},
                width: 16,
                height: 16,
                color: const Color(0xFF333333));
          }),
          SizedBox(width: 20.w),

          /// 播放列表按钮
          GetBuilder<HomeController>(builder: (logic) {
            return touchIconByAsset(
                path: "assets/player/play_playlist.svg",
                onTap: () => {},
                width: 18,
                height: 18,
                color: const Color(0xFF333333));
          }),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }

  Widget miniCover() {
    return InkWell(
      onTap: () => widget.onTap(),
      child: Row(
        children: [
          SizedBox(width: 6.w),
          showImg(
              SDUtils.getImgPath(
                  PlayerLogic.to.playingMusic.value.coverPath ?? ""),
              radius: 50,
              width: 50,
              height: 50,
              hasShadow: false)
        ],
      ),
    );
  }

  Widget marqueeMusicName() {
    final isCanScroll = PlayerLogic.to.isCanMiniPlayerScroll;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onDoubleTap: () => PlayerLogic.to.togglePlay(),
            child: CarouselPlayer(
                listItems: refreshList(PlayerLogic.to.mPlayList,
                    PlayerLogic.to.playingMusic.value),
                sliderController: sliderController,
                isCanScroll: isCanScroll),
          )
        ],
      ),
    );
  }

  List<Widget> refreshList(List<Music> musicList, Music currentMusic) {
    scrollList.clear();
    if (musicList.isEmpty) {
      scrollList.add(const MarqueeText(
          text: TextSpan(text: "暂无歌曲"),
          style: TextStyle(fontSize: 15, color: Color(0xFF333333), height: 1.3),
          speed: 15));
      return scrollList;
    }
    int count = -1;
    for (var music in musicList) {
      count++;
      scrollList.add(MarqueeText(
          text: TextSpan(text: music.name),
          style: const TextStyle(
              fontSize: 15, color: Color(0xFF333333), height: 1.3),
          speed: 15));
      if (music.uid == currentMusic.uid) {
        sliderController.jumpToPage(count);
      }
    }
    return scrollList;
  }
}
