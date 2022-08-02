import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/album_details/widget/details_header.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/details_list_top.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';

class MenuDetailsPage extends StatefulWidget {
  const MenuDetailsPage({Key? key}) : super(key: key);

  @override
  State<MenuDetailsPage> createState() => _MenuDetailsPageState();
}

class _MenuDetailsPageState extends State<MenuDetailsPage> {
  Menu menu = Get.arguments;
  final music = <Music>[];

  @override
  void initState() {
    super.initState();
    final musicList = menu.music;
    if (musicList != null && musicList.isNotEmpty) {
      DBLogic.to.musicDao.findMusicsByMusicIds(musicList).then((value) {
        music.addAll(value);
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      body: Column(
        children: [
          DetailsHeader(
            title: menu.name,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: getListItems(),
            ),
          ),
        ],
      ),
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
        checkedItemLength: music.length,
        onPlayTap: () {},
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
          showImg(
              SDUtils.getImgPath(
                  fileName: music.isNotEmpty
                      ? music[music.length - 1].coverPath!
                      : null),
              240,
              240,
              radius: 120),
        ],
      ),
    );
  }
}
