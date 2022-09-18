import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_playlist.dart';
import 'package:lovelivemusicplayer/utils/image_util.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:marquee_text/marquee_text.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key, required this.onTap}) : super(key: key);
  final GestureTapCallback onTap;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final scrollList = <Widget>[];
  ImageProvider? provider;
  int moveDirection = -1; // -1: 未触发点击; 0: 已触发点击; 1: 左; 1: 右

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(34),
          ),
          child: renderPanel());
    });
  }

  Widget renderPanel() {
    if (GlobalLogic.to.hasSkin.value) {
      final music = PlayerLogic.to.playingMusic.value;
      return FutureBuilder<Decoration>(
        initialData: BoxDecoration(
          color: const Color(0xFFEBF3FE),
          borderRadius: BorderRadius.circular(34),
        ),
        builder: (BuildContext context, AsyncSnapshot<Decoration> snapshot) {
          return Container(
            height: 60.h,
            margin: EdgeInsets.only(top: 2.h, left: 16.w, right: 16.w),
            decoration: snapshot.requireData,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: BackdropFilter(
                  //背景滤镜
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  //背景模糊化
                  child: body(),
                )),
          );
        },
        future: generateDecoration(music),
      );
    }
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(top: 2.h, left: 16.w, right: 16.w),
      child: ClipRRect(borderRadius: BorderRadius.circular(34), child: body()),
    );
  }

  Future<Decoration> generateDecoration(Music music) async {
    String coverPath = (music.baseUrl ?? "") + (music.coverPath ?? "");
    if (coverPath.isEmpty) {
      coverPath = Assets.logoLogo;
    } else {
      coverPath = SDUtils.getImgFile(coverPath).path;
    }
    final compressPic = await ImageUtil().compressAndTryCatch(coverPath);
    return BoxDecoration(
      image:
          DecorationImage(image: MemoryImage(compressPic!), fit: BoxFit.fill),
      borderRadius: BorderRadius.circular(34),
    );
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
          playButton(),
          SizedBox(width: 20.w),

          /// 播放列表按钮
          touchIconByAsset(
              path: Assets.playerPlayPlaylist,
              onTap: () {
                SmartDialog.compatible.show(
                    widget: const DialogPlaylist(),
                    alignmentTemp: Alignment.bottomCenter);
              },
              width: 18,
              height: 18,
              color: Get.isDarkMode
                  ? const Color(0xFFCCCCCC)
                  : const Color(0xFF333333)),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }

  Widget miniCover() {
    final currentMusic = PlayerLogic.to.playingMusic.value;
    final coverPath =
        (currentMusic.baseUrl ?? "") + (currentMusic.coverPath ?? "");
    return Row(
      children: [
        SizedBox(width: 6.w),
        showImg(SDUtils.getImgPath(fileName: coverPath), 50, 50,
            radius: 50, hasShadow: false, onTap: widget.onTap)
      ],
    );
  }

  void swipe(PointerMoveEvent moveEvent) {
    if (moveDirection != -1) {
      double angle = ((moveEvent.delta.direction * 180) / pi);
      if (angle >= -45 && angle <= 45) {
        moveDirection = 2;
      } else if (angle >= 45 && angle <= 135) {
      } else if (angle <= -45 && angle >= -135) {
      } else {
        moveDirection = 1;
      }
    }
  }

  Widget marqueeMusicName() {
    return Expanded(
        child: Listener(
      onPointerDown: (event) {
        moveDirection = 0;
      },
      onPointerMove: (event) {
        swipe(event);
      },
      onPointerUp: (event) {
        if (moveDirection == 1) {
          PlayerLogic.to.playNext();
        } else if (moveDirection == 2) {
          PlayerLogic.to.playPrev();
        }
        moveDirection = -1;
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: renderPlayingWidget(PlayerLogic.to.playingMusic.value.musicName),
      ),
    ));
  }

  Widget renderPlayingWidget(String? musicName) {
    const textStyle = TextStyle(fontWeight: FontWeight.bold);
    return SizedBox(
      width: 180.w,
      child: InkWell(
        onDoubleTap: () {
          if (PlayerLogic.to.playingMusic.value.musicId != null) {
            PlayerLogic.to.togglePlay();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MarqueeText(
                text: TextSpan(text: musicName ?? "暂无歌曲"),
                style: Get.isDarkMode
                    ? TextStyleMs.white_14.merge(textStyle)
                    : TextStyleMs.black_14.merge(textStyle),
                speed: 15)
          ],
        ),
      ),
    );
  }

  Widget playButton() {
    return Container(
        padding: EdgeInsets.only(left: 10.w, top: 10.w, bottom: 10.w),
        child: StreamBuilder<PlayerState>(
          stream: PlayerLogic.to.mPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            final color = Get.isDarkMode
                ? const Color(0xFFCCCCCC)
                : const Color(0xFF333333);
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 16.h,
                height: 16.h,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return touchIconByAsset(
                  path: Assets.playerPlayPlay,
                  onTap: () {
                    if (PlayerLogic.to.playingMusic.value.musicId != null) {
                      PlayerLogic.to.mPlayer.play();
                    }
                  },
                  width: 16,
                  height: 16,
                  color: color);
            } else if (processingState != ProcessingState.completed) {
              return touchIconByAsset(
                  path: Assets.playerPlayPause,
                  onTap: () => PlayerLogic.to.mPlayer.pause(),
                  width: 16,
                  height: 16,
                  color: color);
            } else {
              return touchIconByAsset(
                  path: Assets.playerPlayPlay,
                  onTap: () => PlayerLogic.to.mPlayer.seek(Duration.zero,
                      index: PlayerLogic.to.mPlayer.effectiveIndices!.first),
                  width: 16,
                  height: 16,
                  color: color);
            }
          },
        ));
  }
}
