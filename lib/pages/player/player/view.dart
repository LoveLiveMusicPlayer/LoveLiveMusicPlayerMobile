import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_lyric.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/position_data.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/control_buttons.dart';
import 'package:lovelivemusicplayer/pages/player/player/logic.dart';
import 'package:lovelivemusicplayer/pages/player/player/player_type_enum.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_cover.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_lyric.dart';
import 'package:lovelivemusicplayer/pages/player/widget/seekbar.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/tachie_widget.dart';

class PlayerPage extends GetView<PlayerPageLogic> {
  final GestureTapCallback onTap;

  const PlayerPage({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.primaryColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(() {
          return Visibility(
              visible: controller.isOpen.value,
              child: Stack(
                children: <Widget>[
                  coverBg(),
                  Column(
                    children: <Widget>[
                      top(context),
                      bottom(),
                    ],
                  )
                ],
              ));
        }),
      ),
    );
  }

  /// 覆盖背景
  Widget coverBg() {
    final currentMusic = PlayerLogic.to.playingMusic.value;
    final pic = (currentMusic.baseUrl ?? "") + (currentMusic.coverPath ?? "");
    if (!GlobalLogic.to.hasSkin.value) {
      return Container();
    }

    ImageProvider? provider;
    if (pic.isEmpty) {
      provider = const AssetImage(Assets.logoLogo);
    } else if (currentMusic.existFile == true) {
      final file = File(SDUtils.path + pic);
      if (file.existsSync()) {
        provider = FileImage(file);
      }
    } else if (GlobalLogic.to.remoteHttp.canUseHttpUrl()) {
      provider = NetworkImage("${GlobalLogic.to.remoteHttp.httpUrl.value}$pic");
    }
    final decoration = provider == null
        ? BoxDecoration(color: GlobalLogic.to.iconColor.value)
        : BoxDecoration(
            image: DecorationImage(image: provider, fit: BoxFit.cover));
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight,
      child: ClipRRect(
        child: Stack(
          children: [
            Container(decoration: decoration),
            Positioned.fill(
                child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget top(BuildContext context) {
    return Container(
      color: GlobalLogic.to.hasSkin.value
          ? Colors.transparent
          : Get.theme.primaryColor,
      height: 580.h,
      child: Column(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top + 14.56.h),

          /// 头部
          PlayerHeader(
              btnColor: GlobalLogic.to.iconColor.value,
              onCloseTap: onTap,
              onMoreTap: controller.onMoreTap),

          SizedBox(height: 10.h),

          /// 中间可切换的界面
          stackBody(),

          SizedBox(height: 10.h),

          /// 功能栏
          funcButton()
        ],
      ),
    );
  }

  Widget stackBody() {
    if (controller.showContent.value == PlayerType.cover) {
      return Cover(onTap: controller.onCoverTap);
    } else {
      return Stack(
        children: [
          Lyric(
              key: const Key("Lyric"),
              onTap: controller.onLyricTap,
              height: 400.h),
          Center(
            child: Visibility(
                visible: controller.showContent.value == PlayerType.tachie,
                child: const Tachie(canMove: false)),
          )
        ],
      );
    }
  }

  Widget funcButton() {
    final hasSkin = GlobalLogic.to.hasSkin.value;
    final bgColor = hasSkin ? GlobalLogic.to.iconColor.value : null;
    final iconColor = hasSkin ? Colors.white : null;
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: controller.showContent.value == PlayerType.cover
                ? [
                    neumorphicButton(
                        PlayerLogic.to.playingMusic.value.isLove
                            ? Icons.favorite
                            : Assets.playerPlayLove,
                        PlayerLogic.to.toggleLove,
                        iconSize: 18,
                        iconColor: Colors.pinkAccent,
                        hasShadow: !hasSkin,
                        bgColor: bgColor,
                        padding: EdgeInsets.all(7.r)),
                    neumorphicButton(
                      Icons.add,
                      controller.onAddSong,
                      iconSize: 20,
                      iconColor: iconColor,
                      hasShadow: !hasSkin,
                      bgColor: bgColor,
                    )
                  ]
                : [
                    Visibility(
                        visible: hasSkin,
                        child: neumorphicButton(
                            Assets.playerPlayerCall, controller.onTachiTap,
                            iconSize: 20,
                            iconColor: iconColor,
                            hasShadow: !hasSkin,
                            bgColor: bgColor,
                            padding: EdgeInsets.all(7.r))),
                    Visibility(
                        visible: SDUtils.allowEULA,
                        child: neumorphicButton(
                          LyricLogic.renderIcon(),
                          LyricLogic.toggleTranslate,
                          iconSize: 20,
                          padding: EdgeInsets.all(2.r),
                          iconColor: iconColor,
                          hasShadow: !hasSkin,
                          bgColor: bgColor,
                        ))
                  ]));
  }

  Widget bottom() {
    return Container(
      height: 170.h,
      color: GlobalLogic.to.hasSkin.value
          ? Colors.transparent
          : Get.theme.primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /// 滑动条
          slider(),

          SizedBox(height: 20.h),

          /// 播放器控制组件
          const ControlButtons(),
        ],
      ),
    );
  }

  Widget slider() {
    return StreamBuilder<PositionData>(
      stream: controller.positionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;
        return SeekBar(
            duration: positionData?.duration ?? Duration.zero,
            position: positionData?.position ?? Duration.zero,
            onChangeEnd: PlayerLogic.to.seekToPlay);
      },
    );
  }
}
