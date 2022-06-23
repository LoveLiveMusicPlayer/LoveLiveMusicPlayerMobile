import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/carousel/carousel_slider.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_playlist.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
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
            color: Get.theme.primaryColor,
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
          StreamBuilder<PlayerState>(
            stream: PlayerLogic.to.mPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 16,
                  height: 16,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return touchIconByAsset(
                    path: "assets/player/play_play.svg",
                    onTap: () => PlayerLogic.to.mPlayer.play(),
                    width: 16,
                    height: 16,
                    color: const Color(0xFF333333));
              } else if (processingState != ProcessingState.completed) {
                return touchIconByAsset(
                    path: "assets/player/play_pause.svg",
                    onTap: () => PlayerLogic.to.mPlayer.pause(),
                    width: 16,
                    height: 16,
                    color: const Color(0xFF333333));
              } else {
                return touchIconByAsset(
                    path: "assets/player/play_play.svg",
                    onTap: () =>
                        PlayerLogic.to.mPlayer.seek(Duration.zero,
                            index: PlayerLogic.to.mPlayer.effectiveIndices!
                                .first),
                    width: 16,
                    height: 16,
                    color: const Color(0xFF333333));
              }
            },
          ),
          SizedBox(width: 20.w),

          /// 播放列表按钮
          GetBuilder<HomeController>(builder: (logic) {
            return touchIconByAsset(
                path: "assets/player/play_playlist.svg",
                onTap: () {
                  SmartDialog.compatible.show(
                      widget: DialogPlaylist(),
                      alignmentTemp: Alignment.bottomCenter);
                },
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onDoubleTap: () => PlayerLogic.to.togglePlay(),
            // child: FutureBuilder(
            //   initialData: const <Widget>[],
            //   builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
            //     return CarouselPlayer(
            //         listItems: snapshot.requireData,
            //         sliderController: sliderController,
            //         isCanScroll: PlayerLogic.to.isCanMiniPlayerScroll.value);
            //   },
            //   future: refreshList(PlayerLogic.to.playingMusic.value),
            // ),
            child: Text(PlayerLogic.to.playingMusic.value.name ?? "暂无歌曲", style: TextStyleMs.black_14),
          )
        ],
      ),
    );
  }

  Future<List<Widget>>? refreshList(Music currentMusic) async {
    final musicList = PlayerLogic.to.mPlayList;
    scrollList.clear();
    if (musicList.isEmpty) {
      scrollList.add(boxView("暂无歌曲"));
      return scrollList;
    }
    int count = -1;
    int? currentIndex;
    for (var music in musicList) {
      count++;
      scrollList.add(boxView(music.name));
      if (currentIndex == null && music.uid == currentMusic.uid) {
        currentIndex = count;
      }
    }
    sliderController.jumpToPage(currentIndex ?? 0);
    return scrollList;
  }

  Widget boxView(text) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MarqueeText(
              text: TextSpan(text: text),
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF333333), height: 1.3),
              speed: 15)
        ],
      ),
    );
  }
}
