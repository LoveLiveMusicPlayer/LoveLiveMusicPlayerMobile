import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_lyric.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/drive/logic.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/player_util.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/my_appbar.dart';
import 'package:lovelivemusicplayer/widgets/swipe_image_carousel.dart';
import 'package:marquee_text/marquee_text.dart';

class DriveModePage extends GetView<DriveModeLogic> {
  const DriveModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Obx(() {
          final bgColor =
              Get.isDarkMode ? ColorMs.color1E2328 : ColorMs.colorLightPrimary;
          return Scaffold(
              backgroundColor:
                  Get.isDarkMode ? ColorMs.color2B333A : ColorMs.colorE7F2FF,
              appBar: MyAppbar(backgroundColor: bgColor),
              body: SafeArea(
                  child: Container(
                      padding: EdgeInsets.only(top: 10.h),
                      color: bgColor,
                      child: body())));
        }));
  }

  Widget body() {
    final music = PlayerLogic.to.playingMusic.value;
    return Column(
      children: [
        const Expanded(child: SwipeImageCarousel()),
        SizedBox(
          height: 280.h,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 34.h,
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                child: MarqueeText(
                    text: TextSpan(text: music.musicName ?? 'no_songs'.tr),
                    style: Get.isDarkMode
                        ? TextStyleMs.whiteBold_24
                        : TextStyleMs.blackBold_24,
                    textAlign: TextAlign.center,
                    speed: 15),
              ),
              SizedBox(height: 5.h),
              Stack(
                children: [
                  Container(
                      width: double.infinity,
                      height: 60.h,
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(LyricLogic.playingJPLrc.value.current ?? "",
                          style: Get.isDarkMode
                              ? TextStyleMs.white_20
                              : TextStyleMs.black_20,
                          maxLines: 2,
                          textAlign: TextAlign.center)),
                  Column(
                    children: [
                      SizedBox(height: 84.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          neumorphicButton(
                              music.isLove
                                  ? Assets.driveCarFavoriate
                                  : Assets.driveCarDisFavorite,
                              controller.toggleLove,
                              width: 58,
                              height: 58,
                              iconColor: music.isLove
                                  ? const Color(0xFFF940A7)
                                  : Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                              hasShadow: false),
                          SizedBox(width: 38.w),
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: SizedBox(
                                height: 90.h,
                                width: 90.h,
                                child: renderPlayButton()),
                          ),
                          SizedBox(width: 38.w),
                          renderPlayMode(),
                        ],
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        Container(
          height: 100.h,
          decoration: BoxDecoration(
              color: Get.isDarkMode ? ColorMs.color2B333A : ColorMs.colorE7F2FF,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.w),
                  topRight: Radius.circular(16.w))),
          child: Row(
            children: [
              renderBottomItem(
                  text: 'exit'.tr,
                  assetPath: Assets.driveCarExit,
                  onTap: () => Get.back(),
                  color: const Color(0xFFED6A65)),
              renderBottomItem(
                  text: 'iLove'.tr,
                  assetPath: Assets.driveCarFavoriteBottom,
                  onTap: () => controller.playILoveMusic(),
                  color: const Color(0xFFE650A4)),
              renderBottomItem(
                  text: 'history'.tr,
                  assetPath: Assets.driveCarPlaylistBottom,
                  onTap: () => controller.playHistoryMusic(),
                  color: const Color(0xFF7FCB90)),
            ],
          ),
        )
      ],
    );
  }

  Widget renderPlayButton() {
    return StreamBuilder<PlayerState>(
      stream: PlayerLogic.to.mPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        final color = Get.isDarkMode ? Colors.white : Colors.black;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 90.h,
            height: 90.h,
            child: const CircularProgressIndicator(),
          );
        } else {
          bool isPlayingNow = playing == true;
          return neumorphicButton(
              isPlayingNow
                  ? Assets.driveCarPlayButton
                  : Assets.driveCarPauseButton,
              () => controller.togglePlay(isPlayingNow, processingState),
              width: 90,
              height: 90,
              iconColor: color,
              hasShadow: false);
        }
      },
    );
  }

  Widget renderPlayMode() {
    final player = PlayerLogic.to.mPlayer;
    return StreamBuilder<LoopMode>(
      stream: player.loopModeStream,
      builder: (context, snapshot) {
        final loopMode = PlayerUtil.calcLoopMode(snapshot.data);
        return neumorphicButton(PlayerUtil.getLoopIconFromLoopMode(loopMode),
            () => PlayerUtil.changeLoopModeByLoopTap(loopMode),
            width: 48,
            height: 48,
            iconColor: Get.isDarkMode ? Colors.white : Colors.black,
            margin: EdgeInsets.only(left: 2.w),
            hasShadow: false);
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
          neumorphicButton(assetPath, onTap,
              width: 40,
              height: 40,
              iconColor: color,
              padding: EdgeInsets.all(2.w),
              hasShadow: false),
          Text(text, style: TextStyle(color: color, fontSize: 17.h))
        ],
      ),
    );
  }
}
