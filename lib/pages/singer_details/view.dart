import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';

import '../../modules/ext.dart';
import '../../widgets/details_list_top.dart';
import '../../widgets/listview_item_song.dart';
import '../album_details/widget/details_header.dart';
import '../home/widget/dialog_bottom_btn.dart';
import '../home/widget/dialog_more.dart';

class SingerDetailsPage extends StatefulWidget {
  const SingerDetailsPage({Key? key}) : super(key: key);

  @override
  State<SingerDetailsPage> createState() => _SingerDetailsPageState();
}

class _SingerDetailsPageState extends State<SingerDetailsPage> {
  final Artist artist = Get.arguments;

  final music = <Music>[];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _load();
      setState(() {});
    });
  }

  _load() async {
    music.addAll(await DBLogic.to.findAllMusicByArtistBin(artist.artistBin));
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
        DetailsHeader(
          title: artist.name,
        ),
        Expanded(
            child: ListView(
          padding: const EdgeInsets.all(0),
          children: getListItems(),
        )),
      ],
    );
  }

  List<Widget> getListItems() {
    List<Widget> list = [];
    list.add(_buildCover());
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
        padding: EdgeInsets.only(left: 16.h, bottom: 20.h),
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

  Widget _buildCover() {
    return Container(
      padding: EdgeInsets.only(top: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          showImg(artist.photo, 240, 240, radius: 120),
        ],
      ),
    );
  }
}
