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
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/models/position_data.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/control_buttons.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_cover.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_lyric.dart';
import 'package:lovelivemusicplayer/pages/player/widget/seekbar.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/tachie_widget.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;

class Player extends StatefulWidget {
  final GestureTapCallback onTap;

  const Player({Key? key, required this.onTap}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

enum Type { cover, lyric, tachie }

class _PlayerState extends State<Player> {
  StreamSubscription? loginSubscription;

  // 是否是封面
  var showContent = Type.cover;

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
      if (showContent != Type.cover && event.isOpen) {
        setStatus(cover: true, open: event.isOpen);
      } else {
        setStatus(open: event.isOpen);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    loginSubscription?.cancel();
    stopServer();
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
                SmartDialog.show(
                    alignment: Alignment.bottomCenter,
                    builder: (context) {
                      return DialogMoreWithMusic(
                          music: Music.deepClone(
                              PlayerLogic.to.playingMusic.value),
                          isPlayer: true,
                          onClosePanel: () {
                            GlobalLogic.mobileWeSlideController.hide();
                            GlobalLogic.to.needHomeSafeArea.value = true;
                            GlobalLogic.mobileWeSlideFooterController.hide();
                          },
                          changeLoveStatusCallback: (status) {
                            PlayerLogic.to.playingMusic.value = Music.deepClone(
                                PlayerLogic.to.playingMusic.value);
                          });
                    });
                SmartDialog.show(
                    alignment: Alignment.bottomCenter,
                    builder: (context) {
                      return DialogMoreWithMusic(
                          music: Music.deepClone(
                              PlayerLogic.to.playingMusic.value),
                          isPlayer: true,
                          onClosePanel: () {
                            GlobalLogic.mobileWeSlideController.hide();
                            GlobalLogic.to.needHomeSafeArea.value = true;
                            GlobalLogic.mobileWeSlideFooterController.hide();
                          },
                          changeLoveStatusCallback: (status) {
                            PlayerLogic.to.playingMusic.value = Music.deepClone(
                                PlayerLogic.to.playingMusic.value);
                          });
                    });
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
    stopServer();
    if (cover != null && cover != (showContent == Type.cover)) {
      showContent = cover ? Type.cover : Type.lyric;
    }
    if (open != null && open != isOpen) {
      isOpen = open;
    }
    setState(() {});
  }

  Widget stackBody() {
    if (showContent == Type.cover) {
      return Cover(onTap: () {
        setStatus(cover: false);
        PlayerLogic.to.needRefreshLyric.value = true;
      });
    } else {
      return Stack(
        children: [
          Lyric(
              key: const Key("Lyric"),
              onTap: () => setStatus(cover: true),
              height: 400.h),
          Center(
            child: Visibility(
                visible: showContent == Type.tachie,
                child: const Tachie(canMove: false)),
          )
        ],
      );
    }
  }

  Widget funcButton() {
    if (showContent != Type.cover) {
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
            Visibility(
                visible: GlobalLogic.to.hasSkin.value,
                child: materialButton(Assets.playerPlayerCall, () {
                  if (showContent == Type.lyric) {
                    startServer();
                    showContent = Type.tachie;
                  } else {
                    showContent = Type.lyric;
                  }
                  setState(() {});
                  PlayerLogic.to.needRefreshLyric.value = true;
                },
                    width: 32,
                    height: 32,
                    radius: 6,
                    iconSize: 20,
                    hasShadow: !GlobalLogic.to.hasSkin.value,
                    iconColor:
                        GlobalLogic.to.hasSkin.value ? Colors.white : null,
                    bgColor: GlobalLogic.to.hasSkin.value
                        ? GlobalLogic.to.iconColor.value
                        : null,
                    outerColor: GlobalLogic.to.hasSkin.value
                        ? GlobalLogic.to.iconColor.value
                        : null)),
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
              () async => await PlayerLogic.to.toggleLove(),
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
            SmartDialog.show(builder: (context) {
              return DialogAddSongSheet(
                musicList: [Music.deepClone(PlayerLogic.to.playingMusic.value)],
                changeLoveStatusCallback: (status) async {
                  PlayerLogic.to.playingMusic.value =
                      Music.deepClone(PlayerLogic.to.playingMusic.value);
                },
              );
            });
            SmartDialog.show(
                alignment: Alignment.bottomCenter,
                builder: (context) {
                  return DialogAddSongSheet(
                    musicList: [
                      Music.deepClone(PlayerLogic.to.playingMusic.value)
                    ],
                    changeLoveStatusCallback: (status) async {
                      PlayerLogic.to.playingMusic.value =
                          Music.deepClone(PlayerLogic.to.playingMusic.value);
                    },
                  );
                });
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

    ImageProvider? provider;
    if (pic.isEmpty) {
      provider = const AssetImage(Assets.logoLogo);
    } else if (currentMusic.existFile == true) {
      final file = File(SDUtils.path + pic);
      if (file.existsSync()) {
        provider = FileImage(file);
      }
    } else if (remoteHttp.canUseHttpUrl()) {
      provider = NetworkImage("${remoteHttp.httpUrl.value}$pic");
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
            Container(
              decoration: decoration,
            ),
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
}
