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

import '../../modules/ext.dart';
import '../../utils/sd_utils.dart';
import '../../widgets/details_list_top.dart';
import '../../widgets/listview_item_song.dart';
import '../album_details/widget/details_header.dart';
import '../home/widget/dialog_bottom_btn.dart';
import '../home/widget/dialog_more.dart';
import 'logic.dart';

class SingerDetailsPage extends StatefulWidget {
  @override
  State<SingerDetailsPage> createState() => _SingerDetailsPageState();
}

class _SingerDetailsPageState extends State<SingerDetailsPage> {
  final logic = Get.put(SingerDetailsLogic());

  final state = Get.find<SingerDetailsLogic>().state;

  final Album album = Get.arguments;

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
    music.addAll(await DBLogic.to.findAllMusicsByAlbumId(album.albumId!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F8FF),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        DetailsHeader(
          title: "Liella!",
        ),
        Expanded(
          child: GetBuilder<SingerDetailsLogic>(builder: (logic) {
            return ListView(
              padding: const EdgeInsets.all(0),
              children: getListItems(),
            );
          }),
        ),
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
        selectAll: logic.state.selectAll,
        isSelect: logic.state.isSelect,
        itemsLength: music.length,
        checkedItemLength: logic.getCheckedSong(),
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
        padding: EdgeInsets.only(left: 16.h, bottom: 20.h),
        child: ListViewItemSong(
          index: index,
          music: music[index],
          checked: logic.isItemChecked(music[index]),
          onItemTap: (index, checked) {
            logic.selectItem(index, checked);
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
          showImg(SDUtils.getImgPath("ic_head.jpg"), 240, 240, radius: 120),
        ],
      ),
    );
  }
}
