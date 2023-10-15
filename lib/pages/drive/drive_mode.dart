import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/my_appbar.dart';
import 'package:lovelivemusicplayer/widgets/swipe_image_carousel.dart';
import 'package:marquee_text/marquee_text.dart';

class DriveMode extends StatefulWidget {
  const DriveMode({super.key});

  @override
  State<DriveMode> createState() => _DriveModeState();
}

class _DriveModeState extends State<DriveMode> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Obx(() {
          return Scaffold(
              backgroundColor: ColorMs.color2B333A,
              appBar: MyAppbar(backgroundColor: ColorMs.color1E2328),
              body: SafeArea(
                  child: Container(
                padding: EdgeInsets.only(top: 10.h),
                color: ColorMs.color1E2328,
                child: Column(
                  children: [
                    Expanded(
                      child: SwipeImageCarousel(
                        currentPlay: PlayerLogic.to.playingMusic.value
                      ),
                    ),
                    SizedBox(
                      height: 280.h,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 34.h,
                            margin: EdgeInsets.symmetric(horizontal: 24.w),
                            child: MarqueeText(
                                text: TextSpan(
                                    text: PlayerLogic
                                            .to.playingMusic.value.musicName ??
                                        'no_songs'.tr),
                                style: TextStyleMs.whiteBold_24,
                                textAlign: TextAlign.center,
                                speed: 15),
                          ),
                          SizedBox(height: 5.h),
                          Stack(
                            children: [
                              Container(
                                  height: 60.h,
                                  width: double.infinity,
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 24.w),
                                  child: Text(
                                      PlayerLogic.to.playingJPLrc["current"] ??
                                          "",
                                      style: TextStyleMs.white_20,
                                      maxLines: 2,
                                      textAlign: TextAlign.center)),
                              Column(
                                children: [
                                  SizedBox(height: 84.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      touchIconByAsset(
                                          path: Assets.driveCarDisFavorite,
                                          onTap: () {},
                                          width: 38.w,
                                          height: 38.w,
                                          color: Get.isDarkMode
                                              ? ColorMs.colorCCCCCC
                                              : ColorMs.color666666),
                                      SizedBox(width: 38.w),
                                      Padding(
                                        padding: EdgeInsets.all(8.w),
                                        child: renderPlayButton(),
                                      ),
                                      SizedBox(width: 38.w),
                                      renderPlayMode(),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                    Container(
                      height: 100.h,
                      decoration: BoxDecoration(
                          color: ColorMs.color2B333A,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.w),
                              topRight: Radius.circular(16.w))),
                      child: Row(
                        children: [
                          renderBottomItem(
                              text: "退出",
                              assetPath: Assets.driveCarExit,
                              onTap: () => Get.back(),
                              color: const Color(0xFFED6A65)),
                          renderBottomItem(
                              text: "我喜欢",
                              assetPath: Assets.driveCarFavoriteBottom,
                              onTap: () {},
                              color: const Color(0xFFE650A4)),
                          renderBottomItem(
                              text: "最近播放",
                              assetPath: Assets.driveCarPlaylistBottom,
                              onTap: () {},
                              color: const Color(0xFF7FCB90)),
                        ],
                      ),
                    )
                  ],
                ),
              )));
        }));
  }

  Widget renderPlayButton() {
    return StreamBuilder<PlayerState>(
      stream: PlayerLogic.to.mPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        final color =
            Get.isDarkMode ? ColorMs.colorCCCCCC : ColorMs.color333333;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 90.h,
            height: 90.h,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return touchIconByAsset(
              path: Assets.driveCarPauseButton,
              onTap: () {
                if (PlayerLogic.to.playingMusic.value.musicId != null) {
                  PlayerLogic.to.mPlayer.play();
                }
              },
              width: 90,
              height: 90,
              color: color);
        } else if (processingState != ProcessingState.completed) {
          return touchIconByAsset(
              path: Assets.driveCarPlayButton,
              onTap: () => PlayerLogic.to.mPlayer.pause(),
              width: 90,
              height: 90,
              color: color);
        } else {
          return touchIconByAsset(
              path: Assets.driveCarPlayButton,
              onTap: () => PlayerLogic.to.mPlayer.seek(Duration.zero,
                  index: PlayerLogic.to.mPlayer.effectiveIndices!.first),
              width: 90,
              height: 90,
              color: color);
        }
      },
    );
  }

  Widget renderPlayMode() {
    return StreamBuilder<LoopMode>(
      stream: PlayerLogic.to.mPlayer.loopModeStream,
      builder: (context, snapshot) {
        var loopMode = snapshot.data ?? LoopMode.off;
        const icons = [
          Assets.playerPlayShuffle,
          Assets.playerPlayRecycle,
          Assets.playerPlaySingle
        ];
        if (loopMode == LoopMode.all &&
            PlayerLogic.to.mPlayer.shuffleModeEnabled) {
          loopMode = LoopMode.off;
        }
        final index = PlayerLogic.loopModes.indexOf(loopMode);
        return touchIconByAsset(
            path: icons[index],
            onTap: () {
              final currentIndex = PlayerLogic.loopModes.indexOf(loopMode);
              final nextIndex =
                  (currentIndex + 1) % PlayerLogic.loopModes.length;
              PlayerLogic.to.changeLoopMode(nextIndex);
            },
            width: 30.w,
            height: 30.w,
            padding: 4.w,
            color: Get.isDarkMode ? ColorMs.colorCCCCCC : ColorMs.color666666);
      },
    );
  }

  Widget renderBottomItem(
      {required String assetPath,
      required String text,
      required Color color,
      Function()? onTap}) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          touchIconByAsset(
              path: assetPath,
              onTap: onTap,
              width: 30.w,
              height: 30.w,
              padding: 4.w,
              color: color),
          Text(text, style: TextStyle(color: color, fontSize: 17.sp))
        ],
      ),
    );
  }
}
