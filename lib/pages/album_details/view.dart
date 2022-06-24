import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more.dart';
import 'package:lovelivemusicplayer/widgets/details_cover.dart';
import 'package:lovelivemusicplayer/widgets/details_list_top.dart';

import '../../widgets/listview_item_song.dart';
import 'logic.dart';
import 'widget/details_header.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';

class AlbumDetailsPage extends StatelessWidget {
  final logic = Get.put(AlbumDetailsController());
  final state = Get.find<AlbumDetailsController>().state;
  final Album album = Get.arguments;

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
          child: GetBuilder<AlbumDetailsController>(builder: (logic) {
            return ListView(
              padding: const EdgeInsets.all(0),
              children: getListItems(logic),
            );
          }),
        ),
      ],
    );
  }

  List<Widget> getListItems(AlbumDetailsController logic) {
    List<Widget> list = [];
    list.add(DetailsCover(album: album));
    list.add(SizedBox(
      height: 10.h,
    ));
    list.add(DetailsListTop(
        selectAll: logic.state.selectAll,
        isSelect: logic.state.isSelect,
        itemsLength: album.music.length,
        checkedItemLength: logic.getCheckedSong(),
        onPlayTap: () {
          PlayerLogic.to.playMusic(album.music);
        },
        onScreenTap: () {
          logic.openSelect();
          showSelelctDialog();
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
    for (final music in album.music) {
      list.add(Padding(
        padding: EdgeInsets.only(left: 16.w, bottom: 20.h, right: 16.w),
        child: ListViewItemSong(
          music: music,
          checked: logic.isItemChecked(music),
          onItemTap: (index, checked) {
            logic.selectItem(music, checked);
          },
          onPlayTap: (music) {},
          onMoreTap: (music) {
            SmartDialog.compatible.show(
                widget: DialogMore(music: music), alignmentTemp: Alignment.bottomCenter);
          },
        ),
      ));
    }
    return list;
  }

  showSelelctDialog() {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList2,
        title: "加入播放列表",
        onTap: () {}));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList,
        title: "添加到歌单",
        onTap: () {}));
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
