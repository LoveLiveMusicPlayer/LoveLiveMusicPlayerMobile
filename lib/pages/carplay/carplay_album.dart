import 'package:flutter_carplay/carplay_worker.dart';
import 'package:flutter_carplay/models/button/alert_constants.dart';
import 'package:flutter_carplay/models/button/bar_button.dart';
import 'package:flutter_carplay/models/list/list_constants.dart';
import 'package:flutter_carplay/models/list/list_item.dart';
import 'package:flutter_carplay/models/list/list_section.dart';
import 'package:flutter_carplay/models/list/list_template.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_enum.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_util.dart';
import 'package:synchronized/synchronized.dart';

class CarplayAlbum {
  static final _albumList = <CPListItem>[];
  static final _musicList = <CPListItem>[];
  static final List<CPListSection> sectionAlbum = [];

  static CarplayAlbum? _singleton;
  static final Lock _lock = Lock();
  static CPListTemplate? albumTemp;
  static CPListTemplate? musicTemp;

  static CarplayAlbum getInstance() {
    if (_singleton == null) {
      _lock.synchronized(() {
        if (_singleton == null) {
          var singleton = CarplayAlbum._();
          _singleton = singleton;
          _init();
        }
      });
    }
    return _singleton!;
  }

  CarplayAlbum._();

  /// 切歌 && 处于歌曲页二级目录时 更新列表
  refreshList(List<CPListItem> cpList) async {
    if (albumTemp == null) {
      return;
    }

    FlutterCarplay.pop(count: musicTemp == null ? 1 : 2, animated: false);

    final music = await DBLogic.to.findMusicById(cpList.first.uniqueId);
    await openAlbumList(
        music?.group ?? GlobalLogic.to.currentGroup.value, false);
    _musicList.clear();
    _musicList.addAll(cpList);
    _createMusicTemplate(music?.albumName, false);
  }

  static _init() {
    final cpList = <CPListItem>[];
    CarplayUtil.groupMap.forEach((group, image) {
      cpList.add(CPListItem(
          text: CarplayUtil.convertToMainName(group),
          detailText: CarplayUtil.convertToDetailName(group),
          onPress: (complete, self) async {
            GlobalLogic.to.currentGroup.value = group;
            await openAlbumList(group, true);
            complete();
          },
          image: image,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
          elementId: CarplayUtil.genUniqueId(null)));
    });
    sectionAlbum.add(CPListSection(
      items: cpList,
      header: "团组列表",
    ));
  }

  CPListTemplate get() {
    return CPListTemplate(
      sections: sectionAlbum,
      title: "专辑",
      emptyViewTitleVariants: ["暂无"],
      systemIcon: "music.note.list",
    );
  }

  static Future<void> _createAlbumTemplate(bool animated) async {
    albumTemp = CPListTemplate(
      sections: [
        CPListSection(
          items: _albumList,
        )
      ],
      systemIcon: "systemIcon",
      title: CarplayUtil.convertToMainName(GlobalLogic.to.currentGroup.value),
      backButton: CPBarButton(
        title: "Back",
        style: CPBarButtonStyles.none,
        onPress: () {
          FlutterCarplay.pop(animated: true);
          albumTemp = null;
          CarplayUtil.page = CarplayPageType.pageMain;
        },
      ),
    );

    await FlutterCarplay.push(template: albumTemp, animated: animated);
    CarplayUtil.page = CarplayPageType.pageAlbumOne;
  }

  static Future<void> openAlbumList(String group, bool animated) async {
    await DBLogic.to.findAllListByGroup(group);
    _albumList.clear();

    await Future.forEach<Album>(GlobalLogic.to.albumList, (album) {
      _albumList.add(CPListItem(
        elementId: CarplayUtil.genUniqueId(null),
        text: album.albumName ?? "No name",
        detailText: album.date,
        onPress: (complete, cp) async {
          GlobalLogic.to.musicList.value =
              await DBLogic.to.findAllMusicsByAlbumId(album.albumId!);
          await openAlbumMusicList(album);
          complete();
        },
        image: GlobalLogic.to.albumList.length < 20
            ? CarplayUtil.album2Image(album)
            : null,
        accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
      ));
    });

    _createAlbumTemplate(animated);
  }

  static _createMusicTemplate(String? albumName, bool animated) {
    musicTemp = CPListTemplate(
      sections: [
        CPListSection(
          items: _musicList,
        )
      ],
      systemIcon: "systemIcon",
      title: CarplayUtil.splitName(albumName ?? "No name"),
      backButton: CPBarButton(
        title: "Back",
        style: CPBarButtonStyles.none,
        onPress: () {
          FlutterCarplay.pop(animated: true);
          musicTemp = null;
          CarplayUtil.page = CarplayPageType.pageAlbumOne;
        },
      ),
    );

    FlutterCarplay.push(template: musicTemp, animated: animated);
    CarplayUtil.page = CarplayPageType.pageAlbumTwo;
  }

  static Future<void> openAlbumMusicList(Album album) async {
    _musicList.clear();
    final tempList = await DBLogic.to.findAllMusicsByAlbumId(album.albumId!);

    await Future.forEach<Music>(tempList, (music) {
      _musicList.add(CPListItem(
          elementId: CarplayUtil.genUniqueId(music.musicId),
          onPress: (complete, cp) {
            Carplay.handlePlayMusic(complete, cp, _musicList);
          },
          image: tempList.length < 20 ? CarplayUtil.music2Image(music) : null,
          isPlaying: music.musicId == PlayerLogic.to.playingMusic.value.musicId,
          text: music.musicName ?? "No name",
          detailText: music.artist));
    });

    _createMusicTemplate(album.albumName, true);
  }
}
