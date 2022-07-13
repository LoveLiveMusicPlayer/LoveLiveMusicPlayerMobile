import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more.dart';
import 'package:lovelivemusicplayer/widgets/details_cover.dart';
import 'package:lovelivemusicplayer/widgets/details_list_top.dart';

import '../../widgets/listview_item_song.dart';
import 'widget/details_header.dart';

class AlbumDetailsPage extends StatefulWidget {
  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  final Album album = Get.arguments;
  final music = <Music>[];

  @override
  Future<void> initState() async {
    music.addAll(await DBLogic.to.findAllMusicsByAlbumId(album.albumId!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        DetailsHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: getListItems(),
          ),
        ),
      ],
    );
  }

  List<Widget> getListItems() {
    List<Widget> list = [];
    list.add(DetailsCover(album: album));
    list.add(SizedBox(
      height: 10.h,
    ));
    list.add(DetailsListTop(
        selectAll: HomeController.to.state.selectAll,
        isSelect: HomeController.to.state.isSelect.value,
        itemsLength: music.length,
        checkedItemLength: HomeController.to.getCheckedSong(),
        onPlayTap: () {
          PlayerLogic.to.playMusic(music);
        },
        onScreenTap: () {
          if (HomeController.to.state.isSelect.value) {
            SmartDialog.dismiss();
          } else {
            showSelectDialog();
          }
          HomeController.to.openSelect();
        },
        onSelectAllTap: (checked) {
          HomeController.to.selectAll(checked);
        },
        onCancelTap: () {
          HomeController.to.openSelect();
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
          checked: HomeController.to.isItemChecked(index),
          onItemTap: (index, checked) {
            HomeController.to.selectItem(index, checked);
          },
          onPlayNextTap: (music) => PlayerLogic.to.addNextMusic(music),
          onMoreTap: (music) {
            SmartDialog.compatible.show(
                widget: DialogMore(music: music),
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

  showSelectDialog() {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList2, title: "加入播放列表", onTap: () {}));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList, title: "添加到歌单", onTap: () {}));
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
