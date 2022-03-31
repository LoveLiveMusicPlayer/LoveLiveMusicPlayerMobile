import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/widgets/details_cover.dart';
import 'package:lovelivemusicplayer/widgets/details_list_top.dart';

import '../../models/music_Item.dart';
import '../../modules/ext.dart';
import '../../widgets/refresher_widget.dart';
import '../main/widget/dialog_bottom_btn.dart';
import '../main/widget/dialog_more.dart';
import '../../widgets/listview_item_song.dart';
import '../main/widget/song_library_top.dart';
import 'logic.dart';
import 'widget/details_header.dart';

class AlbumDetailsPage extends StatelessWidget {
  final logic = Get.put(AlbumDetailsLogic());
  final state = Get
      .find<AlbumDetailsLogic>()
      .state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        DetailsHeader(),
        Expanded(
          child: GetBuilder<AlbumDetailsLogic>(builder: (logic) {
            return ListView(
              padding: const EdgeInsets.all(0),
              children: getListItems(logic),
            );
          }),
        ),
      ],
    );
  }

  List<Widget> getListItems(AlbumDetailsLogic logic) {
    List<Widget> list = [];
    list.add(DetailsCover());
    list.add(SizedBox(
      height: 10.h,
    ));
    list.add(DetailsListTop(
        selectAll: logic.state.selectAll,
        isSelect: logic.state.isSelect,
        itemsLength: logic.state.items.length,
        checkedItemLength: logic.getCheckedSong(),
        onPlayTap: () {},
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
    for (int index = 0; index < logic.state.items.length; index++) {
      list.add(Padding(
        padding: EdgeInsets.only(left: 16.h, bottom: 20.h),
        child: ListViewItemSong(
          index: index,
          checked: logic.isItemChecked(index),
          isSelect: logic.state.isSelect,
          onItemTap: (index, checked) {
            logic.selectItem(index, checked);
          },
          onPlayTap: (index) {},
          onMoreTap: (index) {
            SmartDialog.show(
                widget: DialogMore(), alignmentTemp: Alignment.bottomCenter);
          },
        ),
      ));
    }
    return list;
  }

  showSelelctDialog() {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: "assets/dialog/ic_add_play_list2.svg",
        title: "加入播放列表",
        onTap: () {}));
    list.add(BtnItem(
        imgPath: "assets/dialog/ic_add_play_list.svg",
        title: "添加到歌单",
        onTap: () {}));
    SmartDialog.show(
        widget: DialogBottomBtn(
          list: list,
        ),
        isPenetrateTemp: true,
        clickBgDismissTemp: false,
        maskColorTemp: Colors.transparent,
        alignmentTemp: Alignment.bottomCenter);
  }
}
