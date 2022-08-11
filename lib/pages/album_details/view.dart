import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/album_details/logic.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/widgets/details_cover.dart';
import 'package:lovelivemusicplayer/widgets/details_list_top.dart';

import '../../widgets/listview_item_song.dart';
import 'widget/details_header.dart';

class AlbumDetailsPage extends StatefulWidget {
  const AlbumDetailsPage({Key? key}) : super(key: key);

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  final Album album = Get.arguments;
  final music = <Music>[];
  final logic = Get.put(DetailController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _load();
      setState(() {});
    });
  }

  _load() async {
    music.addAll(await DBLogic.to.findAllMusicsByAlbumId(album.albumId!));
    logic.state.items = music;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return GetBuilder<DetailController>(builder: (logic) {
      return Column(
        children: [
          DetailsHeader(title: '专辑详情'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: getListItems(logic),
            ),
          ),
        ],
      );
    });
  }

  List<Widget> getListItems(logic) {
    List<Widget> list = [];
    list.add(DetailsCover(album: album));
    list.add(SizedBox(
      height: 10.h,
    ));
    list.add(DetailsListTop(
        selectAll: logic.state.selectAll,
        isSelect: logic.state.isSelect,
        itemsLength: music.length,
        checkedItemLength: logic.getCheckedSong(),
        onPlayTap: () {
          PlayerLogic.to.playMusic(music);
        },
        onScreenTap: () {
          if (logic.state.isSelect) {
            SmartDialog.dismiss();
          } else {
            showSelectDialog(logic);
          }
          logic.openSelect();
        },
        onSelectAllTap: (checked) {
          logic.selectAll(checked);
        },
        onCancelTap: () {
          logic.openSelect();
          SmartDialog.dismiss();
        }));
    list.add(SizedBox(
      height: 10.h,
    ));
    for (var index = 0; index < music.length; index++) {
      list.add(Padding(
        padding: EdgeInsets.only(left: 16.w, bottom: 20.h, right: 16.w),
        child: ListViewItemSong(
          index: index,
          music: music[index],
          checked: logic.isItemChecked(index),
          onItemTap: (index, checked) {
            logic.selectItem(index, checked);
          },
          onPlayNextTap: (music) => PlayerLogic.to.addNextMusic(music),
          onMoreTap: (music) {
            SmartDialog.compatible.show(
                widget: DialogMoreWithMusic(music: music),
                alignmentTemp: Alignment.bottomCenter);
          },
          onPlayNowTap: () {
            PlayerLogic.to.playMusic(music, index: index);
          },
        ),
      ));
    }
    return list;
  }

  showSelectDialog(logic) {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList2,
        title: "加入播放列表",
        onTap: () async {
          final musicList = logic.state.items;
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              print(music.musicName);
              // todo: 添加到播放列表
            }
          });
          logic.openSelect();
        }));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList,
        title: "添加到歌单",
        onTap: () async {
          final musicList = logic.state.items;
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              print(music.musicName);
              // todo: 添加到歌单
            }
          });
          logic.openSelect();
        }));
    SmartDialog.compatible.show(
        widget: DialogBottomBtn(
          list: list,
        ),
        isPenetrateTemp: true,
        clickBgDismissTemp: false,
        maskColorTemp: Colors.transparent,
        alignmentTemp: Alignment.bottomCenter);
  }
}
