import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/love.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay.dart';
import 'package:lovelivemusicplayer/pages/carplay/carplay_enum.dart';
import 'package:synchronized/synchronized.dart';

import 'carplay_util.dart';

class CarplayMine {
  static final List<CPListItem> _loveList = <CPListItem>[];
  static final List<CPListItem> _musicList = <CPListItem>[];
  static final List<CPListSection> sectionMine = [];

  static CarplayMine? _singleton;
  static final Lock _lock = Lock();
  static CPListTemplate? loveTemp;
  static CPListTemplate? menuTemp;

  static Future<CarplayMine> getInstance() async {
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if (_singleton == null) {
          var singleton = CarplayMine._();
          _singleton = singleton;
          await _init();
        }
      });
    }
    return _singleton!;
  }

  CarplayMine._();

  static Future<void> _init() async {
    sectionMine.add(CPListSection(
      items: [
        CPListItem(
            text: "我喜欢",
            onPress: (complete, self) async {
              await _openLoveList();
              complete();
            },
            image: Assets.carplayHeartFill,
            accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
            elementId: CarplayUtil.genUniqueId(null))
      ],
      header: "我喜欢",
    ));

    final cpList = <CPListItem>[];
    final menuList = await DBLogic.to.menuDao.findAllMenus();
    await Future.forEach<Menu>(menuList, (menu) async {
      final firstMusic =
          await DBLogic.to.musicDao.findMusicByUId(menu.music.first);
      cpList.add(CPListItem(
          text: menu.name,
          detailText: menu.isPhone ? "手机" : "电脑",
          onPress: (complete, self) async {
            await _openMenu(menu.id);
            complete();
          },
          image: menuList.length < 20
              ? CarplayUtil.music2Image(firstMusic)
              : null,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
          elementId: CarplayUtil.genUniqueId(null)));
    });

    sectionMine.add(CPListSection(
      items: cpList,
      header: "收藏歌单",
    ));
  }

  CPListTemplate get() {
    return CPListTemplate(
      sections: sectionMine,
      title: "我的",
      emptyViewTitleVariants: ["暂无"],
      systemIcon: "person.fill",
    );
  }

  static _createLoveTemp() {
    loveTemp = CPListTemplate(
      sections: [
        CPListSection(
          items: _loveList,
        )
      ],
      systemIcon: "systemIcon",
      title: "我喜欢",
      backButton: CPBarButton(
        title: "Back",
        style: CPBarButtonStyles.none,
        onPress: () {
          FlutterCarplay.pop(animated: true);
          CarplayUtil.page = CarplayPageType.pageMain;
        },
      ),
    );
  }

  static Future<void> _openLoveList() async {
    await DBLogic.to.findAllLoveListByGroup(Const.groupAll);
    _loveList.clear();
    final allLoves = await DBLogic.to.loveDao.findAllLoves();

    await Future.forEach<Love>(allLoves, (love) async {
      var music = await DBLogic.to.musicDao.findMusicByUId(love.musicId);
      if (music != null) {
        _loveList.add(CPListItem(
          elementId: CarplayUtil.genUniqueId(music.musicId),
          text: music.musicName ?? "No Name",
          detailText: music.artist,
          onPress: (complete, cp) {
            Carplay.handlePlayMusic(complete, cp, _loveList);
          },
          image: allLoves.length < 20 ? CarplayUtil.music2Image(music) : null,
          isPlaying: PlayerLogic.to.playingMusic.value.musicId == love.musicId,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
        ));
      }
    });

    _createLoveTemp();

    await FlutterCarplay.push(
      template: loveTemp,
      animated: true,
    );
    CarplayUtil.page = CarplayPageType.pageMineLove;
  }

  static Future<void> _createMenuTemplate(
      String? menuName, bool animated) async {
    menuTemp = CPListTemplate(
      sections: [
        CPListSection(
          items: _musicList,
        )
      ],
      systemIcon: "systemIcon",
      title: CarplayUtil.splitName(menuName ?? "No name"),
      backButton: CPBarButton(
        title: "Back",
        style: CPBarButtonStyles.none,
        onPress: () {
          FlutterCarplay.pop(animated: true);
          CarplayUtil.page = CarplayPageType.pageMain;
        },
      ),
    );

    await FlutterCarplay.push(
      template: menuTemp,
      animated: animated,
    );
    CarplayUtil.page = CarplayPageType.pageMineMenu;
  }

  static Future<void> _openMenu(int menuId) async {
    _musicList.clear();
    final menu = await DBLogic.to.menuDao.findMenuById(menuId);
    final musicList = await DBLogic.to.findMusicByMusicIds(menu?.music ?? []);
    await Future.forEach<Music>(musicList, (music) {
      _musicList.add(CPListItem(
          text: music.musicName ?? "No name",
          detailText: music.artist,
          onPress: (complete, cp) {
            Carplay.handlePlayMusic(complete, cp, _musicList);
          },
          image: musicList.length < 20 ? CarplayUtil.music2Image(music) : null,
          isPlaying: music.musicId == PlayerLogic.to.playingMusic.value.musicId,
          elementId: CarplayUtil.genUniqueId(music.musicId)));
    });

    await _createMenuTemplate(menu?.name, true);
  }
}
