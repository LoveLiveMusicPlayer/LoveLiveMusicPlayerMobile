import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/player_closable_event.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/PositionData.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/control_buttons.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_cover.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_lyric.dart';
import 'package:lovelivemusicplayer/pages/player/widget/seekbar.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;

class Player extends StatefulWidget {
  final GestureTapCallback onTap;

  const Player({Key? key, required this.onTap}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  StreamSubscription? loginSubscription;

  // 是否是封面
  var isCover = true;

  // 是否被隐藏
  var isOpen = false;

  Stream<PositionData> get _positionDataStream =>
      rx_dart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          PlayerLogic.to.mPlayer.positionStream,
          PlayerLogic.to.mPlayer.bufferedPositionStream,
          PlayerLogic.to.mPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    loginSubscription = eventBus.on<PlayerClosableEvent>().listen((event) {
      /// 点击关闭按钮后确定关闭掉全量歌词界面，防止cpu消耗过多
      if (!isCover && event.isOpen) {
        print("aaa");
        setStatus(cover: true, open: event.isOpen);
      } else {
        print("bbb");
        setStatus(open: event.isOpen);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    loginSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.primaryColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(() {
          return Visibility(
              visible: isOpen,
              child: Stack(
                children: <Widget>[
                  coverBg(),
                  Column(
                    children: <Widget>[
                      top(),
                      bottom(),
                    ],
                  )
                ],
              ));
        }),
      ),
    );
  }

  Widget top() {
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
              onCloseTap: () => widget.onTap(),
              onMoreTap: () {
                if (PlayerLogic.to.playingMusic.value.musicId == null) {
                  return;
                }
                SmartDialog.compatible.show(
                    widget: DialogMoreWithMusic(
                      music: PlayerLogic.to.playingMusic.value,
                      onClosePanel: () {
                        GlobalLogic.mobileWeSlideController.hide();
                        GlobalLogic.to.needHomeSafeArea.value = true;
                        GlobalLogic.mobileWeSlideFooterController.hide();
                      },
                    ),
                    alignmentTemp: Alignment.bottomCenter);
              }),

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
          ControlButtons(PlayerLogic.to.mPlayer),
        ],
      ),
    );
  }

  setStatus({bool? cover, bool? open}) {
    if (cover != null && cover != isCover) {
      isCover = cover;
    }
    if (open != null && open != isOpen) {
      isOpen = open;
    }
    setState(() {});
  }

  Widget stackBody() {
    if (isCover) {
      return Cover(onTap: () {
        setStatus(cover: false);
        PlayerLogic.to.needRefreshLyric.value = true;
      });
    } else {
      return Lyric(
          key: const Key("Lyric"), onTap: () => setStatus(cover: true));
    }
  }

  Widget funcButton() {
    if (!isCover) {
      dynamic icon;
      switch (PlayerLogic.to.lrcType.value) {
        case 0:
          icon = Assets.playerPlayJp;
          break;
        case 1:
          icon = Assets.playerPlayZh;
          break;
        case 2:
          icon = Assets.playerPlayRoma;
          break;
      }
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            materialButton(
                Icons.youtube_searched_for, () => PlayerLogic.to.getLrc(true),
                width: 32,
                height: 32,
                radius: 6,
                iconSize: 20,
                hasShadow: !GlobalLogic.to.hasSkin.value,
                iconColor: GlobalLogic.to.hasSkin.value ? Colors.white : null,
                bgColor: GlobalLogic.to.hasSkin.value
                    ? GlobalLogic.to.iconColor.value
                    : null,
                outerColor: GlobalLogic.to.hasSkin.value
                    ? GlobalLogic.to.iconColor.value
                    : null),
            Visibility(
                visible: SDUtils.allowEULA,
                child: materialButton(
                    icon, () => PlayerLogic.to.toggleTranslate(),
                    width: 32,
                    height: 32,
                    radius: 6,
                    iconSize: 30,
                    hasShadow: !GlobalLogic.to.hasSkin.value,
                    iconColor:
                        GlobalLogic.to.hasSkin.value ? Colors.white : null,
                    bgColor: GlobalLogic.to.hasSkin.value
                        ? GlobalLogic.to.iconColor.value
                        : null,
                    outerColor: GlobalLogic.to.hasSkin.value
                        ? GlobalLogic.to.iconColor.value
                        : null))
          ]));
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          materialButton(
              PlayerLogic.to.playingMusic.value.isLove
                  ? Icons.favorite
                  : Assets.playerPlayLove,
              () => PlayerLogic.to.toggleLove(),
              width: 32,
              height: 32,
              radius: 6,
              iconColor: Colors.pinkAccent,
              iconSize: 15,
              hasShadow: !GlobalLogic.to.hasSkin.value,
              bgColor: GlobalLogic.to.hasSkin.value
                  ? GlobalLogic.to.iconColor.value
                  : null,
              outerColor: GlobalLogic.to.hasSkin.value
                  ? GlobalLogic.to.iconColor.value
                  : null),
          materialButton(Icons.add, () {
            if (PlayerLogic.to.playingMusic.value.musicId == null) {
              return;
            }
            SmartDialog.compatible.show(
                widget: DialogAddSongSheet(
                    musicList: [PlayerLogic.to.playingMusic.value]),
                alignmentTemp: Alignment.bottomCenter);
          },
              width: 32,
              height: 32,
              radius: 6,
              iconSize: 20,
              hasShadow: !GlobalLogic.to.hasSkin.value,
              iconColor: GlobalLogic.to.hasSkin.value ? Colors.white : null,
              bgColor: GlobalLogic.to.hasSkin.value
                  ? GlobalLogic.to.iconColor.value
                  : null,
              outerColor: GlobalLogic.to.hasSkin.value
                  ? GlobalLogic.to.iconColor.value
                  : null),
        ],
      ),
    );
  }

  Widget slider() {
    return StreamBuilder<PositionData>(
      stream: _positionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;
        return SeekBar(
          duration: positionData?.duration ?? Duration.zero,
          position: positionData?.position ?? Duration.zero,
          onChangeEnd: (newPosition) {
            PlayerLogic.to.mPlayer.seek(newPosition);
          },
        );
      },
    );
  }

  /// 覆盖背景
  Widget coverBg() {
    final currentMusic = PlayerLogic.to.playingMusic.value;
    final pic = (currentMusic.baseUrl ?? "") + (currentMusic.coverPath ?? "");
    if (!GlobalLogic.to.hasSkin.value) {
      return Container();
    }

    ImageProvider provider;
    if (pic.isEmpty) {
      provider = const AssetImage(Assets.logoLogo);
    } else {
      provider = FileImage(File(SDUtils.path + pic));
    }
    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight,
      child: ClipRRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(image: provider, fit: BoxFit.cover)),
            ),
            Positioned.fill(
                child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
