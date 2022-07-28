import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_playlist.dart';
import 'package:lovelivemusicplayer/utils/image_util.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:marquee_text/marquee_text.dart';

import '../../modules/ext.dart';

class MiniPlayer extends StatefulWidget {
  MiniPlayer({Key? key, required this.onTap}) : super(key: key);
  final GestureTapCallback onTap;

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final scrollList = <Widget>[];
  ImageProvider? provider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final music = PlayerLogic.to.playingMusic.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          children: [
            FutureBuilder<Decoration>(
              initialData: BoxDecoration(
                color: const Color(0xFFEBF3FE),
                borderRadius: BorderRadius.circular(34),
              ),
              builder:
                  (BuildContext context, AsyncSnapshot<Decoration> snapshot) {
                return Container(
                  height: 60.h,
                  margin: EdgeInsets.only(left: 16.w, right: 16.w),
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
            ),
          ],
        ),
      );
    });
  }

  Future<Decoration> generateDecoration(Music music) async {
    Decoration decoration;
    if (music.musicId == null ||
        music.coverPath == null ||
        music.coverPath!.isEmpty) {
      decoration = BoxDecoration(
        color: const Color(0xFFEBF3FE),
        borderRadius: BorderRadius.circular(34),
      );
    } else {
      final compressPic = await ImageUtil()
          .compressAndTryCatch(SDUtils.getImgFile(music.coverPath!).path);
      decoration = BoxDecoration(
        image:
            DecorationImage(image: MemoryImage(compressPic!), fit: BoxFit.fill),
        borderRadius: BorderRadius.circular(34),
      );
    }
    return decoration;
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
                    widget: DialogPlaylist(),
                    alignmentTemp: Alignment.bottomCenter);
              },
              width: 18,
              height: 18,
              color: const Color(0xFF333333)),
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
              50,
              50,
              radius: 50,
              hasShadow: false)
        ],
      ),
    );
  }

  Widget marqueeMusicName() {
    return Expanded(
      child: InkWell(
        onDoubleTap: () => PlayerLogic.to.togglePlay(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MarqueeText(
                text: TextSpan(
                    text:
                        PlayerLogic.to.playingMusic.value.musicName ?? "暂无歌曲"),
                style: TextStyleMs.black_14,
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
                onTap: () => PlayerLogic.to.mPlayer.play(),
                width: 16,
                height: 16,
                color: const Color(0xFF333333));
          } else if (processingState != ProcessingState.completed) {
            return touchIconByAsset(
                path: Assets.playerPlayPause,
                onTap: () => PlayerLogic.to.mPlayer.pause(),
                width: 16,
                height: 16,
                color: const Color(0xFF333333));
          } else {
            return touchIconByAsset(
                path: Assets.playerPlayPlay,
                onTap: () => PlayerLogic.to.mPlayer.seek(Duration.zero,
                    index: PlayerLogic.to.mPlayer.effectiveIndices!.first),
                width: 16,
                height: 16,
                color: const Color(0xFF333333));
          }
        },
      )
    );
  }
}
