import 'dart:async';

import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

class Carplay {
  static Carplay? _singleton;
  static final Lock _lock = Lock();
  static String? currentPlayingUniqueId;
  static final List<CPListSection> sectionMusic = [];
  static final musicList = <CPListItem>[];
  static final albumList = <CPListItem>[];

  static Carplay getInstance() {
    if (_singleton == null) {
      _lock.synchronized(() {
        if (_singleton == null) {
          var singleton = Carplay._();
          singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton!;
  }

  Carplay._();

  CPConnectionStatusTypes connectionStatus = CPConnectionStatusTypes.unknown;
  final FlutterCarplay _flutterCarplay = FlutterCarplay();

  void _init() {
    sectionMusic.add(CPListSection(
      items: [
        CPListItem(
            text: "当前播放: 暂无歌曲",
            isPlaying: false,
            playbackProgress: 0,
            image: Assets.logoLogo,
            onPress: (complete, self) async {
              print("随机播放");
              await DBLogic.to.findAllListByGroup(Const.groupAll);
              await PlayerLogic.to.changeLoopMode(0);
              await PlayerLogic.to
                  .playMusic(GlobalLogic.to.filterMusicListByAlbums(0));
              complete();
            },
            elementId: genUniqueId(null)),
      ],
      header: "音乐盲盒",
    ));
    sectionMusic.add(CPListSection(
      items: [
        CPListItem(
            text: convertToName(Const.groupUs),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupUs;
              await openMusicList();
              complete();
            },
            image: Assets.logoLogoUs,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupAqours),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupAqours;
              await openMusicList();
              complete();
            },
            image: Assets.logoLogoAqours,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupSaki),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupSaki;
              await openMusicList();
              complete();
            },
            image: Assets.logoLogoNiji,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupLiella),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupLiella;
              await openMusicList();
              complete();
            },
            image: Assets.logoLogoLiella,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupHasunosora),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupHasunosora;
              await openMusicList();
              complete();
            },
            image: Assets.logoLogoHasunosora,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupYohane),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupYohane;
              await openMusicList();
              complete();
            },
            image: Assets.logoLogoYohane,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupCombine),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupCombine;
              await openMusicList();
              complete();
            },
            image: Assets.logoLogoCombine,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
      ],
      header: "团组列表",
    ));

    final List<CPListSection> sectionAlbum = [];
    sectionAlbum.add(CPListSection(
      items: [
        CPListItem(
            text: convertToName(Const.groupUs),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupUs;
              await openAlbumList();
              complete();
            },
            image: Assets.logoLogoUs,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupAqours),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupAqours;
              await openAlbumList();
              complete();
            },
            image: Assets.logoLogoAqours,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupSaki),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupSaki;
              await openAlbumList();
              complete();
            },
            image: Assets.logoLogoNiji,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupLiella),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupLiella;
              await openAlbumList();
              complete();
            },
            image: Assets.logoLogoLiella,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupHasunosora),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupHasunosora;
              await openAlbumList();
              complete();
            },
            image: Assets.logoLogoHasunosora,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupYohane),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupYohane;
              await openAlbumList();
              complete();
            },
            image: Assets.logoLogoYohane,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
        CPListItem(
            text: convertToName(Const.groupCombine),
            detailText: "u咩",
            onPress: (complete, self) async {
              GlobalLogic.to.currentGroup.value = Const.groupCombine;
              await openAlbumList();
              complete();
            },
            image: Assets.logoLogoCombine,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: genUniqueId(null)),
      ],
      header: "团组列表",
    ));

    FlutterCarplay.setRootTemplate(
      rootTemplate: CPTabBarTemplate(
        templates: [
          CPListTemplate(
            sections: sectionMusic,
            title: "歌曲",
            systemIcon: "music.note.house",
          ),
          CPListTemplate(
            sections: sectionAlbum,
            title: "专辑",
            systemIcon: "music.note.list",
          ),
          CPListTemplate(
            sections: [],
            title: "我的",
            emptyViewTitleVariants: ["Settings"],
            emptyViewSubtitleVariants: [
              "No settings have been added here yet. You can start adding right away"
            ],
            systemIcon: "person.fill",
          ),
        ],
      ),
      animated: true,
    );

    _flutterCarplay.forceUpdateRootTemplate();

    _flutterCarplay.addListenerOnConnectionChange(onCarplayConnectionChange);

    Future.delayed(const Duration(seconds: 1)).then((value) {
      changeMusicByMusic(PlayerLogic.to.playingMusic.value);
    });
  }

  void changeMusicByMusic(Music music) {
    int index = -1;
    for (var i = 0; i < musicList.length; i++) {
      if (musicList[i].isPlaying == true) {
        musicList[i].setIsPlaying(false);
      }
      if (musicList[i].uniqueId == music.musicId) {
        index = i;
      }
    }
    if (index > -1) {
      currentPlayingUniqueId = music.musicId;
      musicList[index].setIsPlaying(true);
    }
    String? imagePath;
    if (music.existFile == true) {
      imagePath = "file://${SDUtils.path}${music.baseUrl}${music.coverPath}";
    } else if (remoteHttp.canUseHttpUrl()) {
      imagePath =
          "${remoteHttp.httpUrl.value}${music.baseUrl}${music.coverPath}";
    }
    sectionMusic[0].items[0].updateTextAndImage(
        "当前播放: ${music.musicName ?? "暂无歌曲"}", imagePath ?? Assets.logoLogo);
  }

  void onCarplayConnectionChange(CPConnectionStatusTypes status) {
    connectionStatus = status;
  }

  Function handlePlayMusic = (Function() complete, CPListItem cp) async {
    for (var element in musicList) {
      if (element.isPlaying == true) {
        element.setIsPlaying(false);
      }
    }
    cp.setIsPlaying(true);
    currentPlayingUniqueId = cp.uniqueId;
    for (var i = 0; i < GlobalLogic.to.musicList.length; i++) {
      if (GlobalLogic.to.musicList[i].musicId == cp.uniqueId) {
        var completer = Completer<void>();
        await PlayerLogic.to
            .playMusic(GlobalLogic.to.musicList, mIndex: i)
            .then((_) => completer.complete());
        await completer.future;
        break;
      }
    }
    complete();
  };

  Future<void> openMusicList() async {
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
    musicList.clear();
    await Future.forEach<Music>(GlobalLogic.to.musicList, (music) {
      musicList.add(CPListItem(
          text: music.musicName ?? "No name",
          onPress: (complete, cp) => handlePlayMusic(complete, cp),
          isPlaying: music.musicId == currentPlayingUniqueId,
          elementId: genUniqueId(music.musicId)));
    });

    await FlutterCarplay.push(
      template: CPListTemplate(
        sections: [
          CPListSection(
            items: musicList,
          )
        ],
        systemIcon: "systemIcon",
        title: convertToName(GlobalLogic.to.currentGroup.value),
        backButton: CPBarButton(
          title: "Back",
          style: CPBarButtonStyles.none,
          onPress: () {
            FlutterCarplay.pop(animated: true);
          },
        ),
      ),
      animated: true,
    );
  }

  Future<void> openAlbumList() async {
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
    albumList.clear();
    await Future.forEach<Album>(GlobalLogic.to.albumList, (album) {
      albumList.add(CPListItem(
        elementId: genUniqueId(album.albumId),
        text: album.albumName ?? "No name",
        onPress: (complete, cp) async {
          GlobalLogic.to.musicList.value =
              await DBLogic.to.findAllMusicsByAlbumId(album.albumId!);
          await openAlbumMusicList(album);
          complete();
        },
        accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
      ));
    });

    await FlutterCarplay.push(
      template: CPListTemplate(
        sections: [
          CPListSection(
            items: albumList,
          )
        ],
        systemIcon: "systemIcon",
        title: convertToName(GlobalLogic.to.currentGroup.value),
        backButton: CPBarButton(
          title: "Back",
          style: CPBarButtonStyles.none,
          onPress: () {
            FlutterCarplay.pop(animated: true);
          },
        ),
      ),
      animated: true,
    );
  }

  Future<void> openAlbumMusicList(Album album) async {
    musicList.clear();
    final tempList = await DBLogic.to.findAllMusicsByAlbumId(album.albumId!);
    await Future.forEach<Music>(tempList, (music) {
      musicList.add(CPListItem(
          elementId: genUniqueId(music.musicId),
          onPress: (complete, cp) => handlePlayMusic(complete, cp),
          text: music.musicName ?? "No name"));
    });
    FlutterCarplay.push(
      template: CPListTemplate(
        sections: [
          CPListSection(
            items: musicList,
          )
        ],
        systemIcon: "systemIcon",
        title: splitName(album.albumName ?? "No name"),
        backButton: CPBarButton(
          title: "Back",
          style: CPBarButtonStyles.none,
          onPress: () {
            FlutterCarplay.pop(animated: true);
          },
        ),
      ),
      animated: true,
    );
  }

  String genUniqueId(String? musicId) {
    return musicId ?? const Uuid().v4();
  }

  String convertToName(String group) {
    String name = "";
    switch (group) {
      case Const.groupSaki:
        name = "虹咲学园学园偶像同好会";
        break;
      case Const.groupHasunosora:
        name = "莲之空女学院";
        break;
      case Const.groupYohane:
        name = "幻日夜羽";
        break;
      case Const.groupCombine:
        name = "其他";
        break;
      default:
        name = group;
        break;
    }
    return splitName(name);
  }

  String splitName(String name) {
    String title;
    const maxTitleLength = 30;
    if (name.length > maxTitleLength) {
      title = "${name.substring(0, maxTitleLength)}...";
    } else {
      title = name;
    }
    return title;
  }

  void forceReload() {
    _flutterCarplay.forceUpdateRootTemplate();
  }

  void dispose() {
    _flutterCarplay.removeListenerOnConnectionChange();
  }
}
