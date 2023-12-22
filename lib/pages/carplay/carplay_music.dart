import 'package:flutter_carplay/carplay_worker.dart';
import 'package:flutter_carplay/models/button/alert_constants.dart';
import 'package:flutter_carplay/models/button/bar_button.dart';
import 'package:flutter_carplay/models/list/list_constants.dart';
import 'package:flutter_carplay/models/list/list_item.dart';
import 'package:flutter_carplay/models/list/list_section.dart';
import 'package:flutter_carplay/models/list/list_template.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/group.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_enum.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_util.dart';
import 'package:synchronized/synchronized.dart';

class CarplayMusic {
  static final List<CPListItem> _musicList = <CPListItem>[];

  static CarplayMusic? _singleton;
  static final Lock _lock = Lock();
  static CPListTemplate? temp;

  static CarplayMusic getInstance() {
    if (_singleton == null) {
      _lock.synchronized(() {
        if (_singleton == null) {
          var singleton = CarplayMusic._();
          _singleton = singleton;
          _init();
        }
      });
    }
    return _singleton!;
  }

  CarplayMusic._();

  static _init() {
    Carplay.sectionMusic.add(CPListSection(
      items: [
        CPListItem(
            text: '${'now_playing'.tr}${'no_songs'.tr}',
            detailText: 'throbbing'.tr,
            isPlaying: false,
            playbackProgress: 0,
            image: Assets.logoLogo,
            onPress: (complete, self) async {
              await DBLogic.to.findAllListByGroup(GroupKey.groupAll.getName());
              await PlayerLogic.to.changeLoopMode(0);
              await PlayerLogic.to
                  .playMusic(GlobalLogic.to.filterMusicListByAlbums(0));
              complete();
            },
            elementId: CarplayUtil.genUniqueId(null)),
      ],
      header: 'music_blind_box'.tr,
    ));

    final cpList = <CPListItem>[];
    CarplayUtil.groupMap.forEach((group, image) {
      cpList.add(CPListItem(
          text: CarplayUtil.convertToMainName(group),
          detailText: CarplayUtil.convertToDetailName(group),
          onPress: (complete, self) async {
            GlobalLogic.to.currentGroup.value = group;
            await _openMusicList();
            complete();
          },
          image: image,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
          elementId: CarplayUtil.genUniqueId(null)));
    });

    Carplay.sectionMusic.add(CPListSection(
      items: cpList,
      header: 'group_list'.tr,
    ));
  }

  CPListTemplate get() {
    return CPListTemplate(
      sections: Carplay.sectionMusic,
      title: 'music'.tr,
      emptyViewTitleVariants: ['no_songs'.tr],
      systemIcon: "music.note.house",
    );
  }

  static Future<void> _createTemplate(bool animated) async {
    temp = CPListTemplate(
      sections: [
        CPListSection(
          items: _musicList,
        )
      ],
      systemIcon: "systemIcon",
      title: CarplayUtil.convertToMainName(GlobalLogic.to.currentGroup.value),
      backButton: CPBarButton(
        title: 'back'.tr,
        style: CPBarButtonStyles.none,
        onPress: () {
          FlutterCarplay.pop(animated: true);
          temp = null;
          CarplayUtil.page = CarplayPageType.pageMain;
        },
      ),
    );

    await FlutterCarplay.push(
      template: temp,
      animated: animated,
    );
    CarplayUtil.page = CarplayPageType.pageMusic;
  }

  static Future<void> _openMusicList() async {
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
    _musicList.clear();

    await Future.forEach<Music>(GlobalLogic.to.musicList, (music) {
      _musicList.add(CPListItem(
          text: music.musicName ?? 'unknown'.tr,
          detailText: music.artist,
          onPress: (complete, cp) {
            Carplay.handlePlayMusic(complete, cp, _musicList);
          },
          image: GlobalLogic.to.musicList.length < 20
              ? CarplayUtil.music2Image(music)
              : null,
          elementId: CarplayUtil.genUniqueId(music.musicId)));
    });

    await _createTemplate(true);
  }
}
