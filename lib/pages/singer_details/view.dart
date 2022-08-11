import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/album_details/logic.dart';

import '../../modules/ext.dart';
import '../../widgets/details_list_top.dart';
import '../../widgets/listview_item_song.dart';
import '../album_details/widget/details_header.dart';
import '../home/widget/dialog_bottom_btn.dart';
import '../home/widget/dialog_more_with_music.dart';

class SingerDetailsPage extends StatefulWidget {
  const SingerDetailsPage({Key? key}) : super(key: key);

  @override
  State<SingerDetailsPage> createState() => _SingerDetailsPageState();
}

class _SingerDetailsPageState extends State<SingerDetailsPage> {
  final Artist artist = Get.arguments;
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
    music.addAll(await DBLogic.to.findAllMusicByArtistBin(artist.artistBin));
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
          DetailsHeader(
            title: artist.name,
          ),
          Expanded(
              child: ListView(
            padding: const EdgeInsets.all(0),
            children: getListItems(logic),
          )),
        ],
      );
    });
  }

  List<Widget> getListItems(logic) {
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
        onPlayTap: () {
          PlayerLogic.to.playMusic(music);
        },
        onScreenTap: () {
          if (logic.state.isSelect) {
            logic.closeSelect();
            SmartDialog.dismiss();
          } else {
            logic.openSelect();
            showSelectDialog(logic);
          }
        },
        onSelectAllTap: (checked) {
          logic.selectAll(checked);
        },
        onCancelTap: () {
          logic.closeSelect();
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
          logic.closeSelect();
        }));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList,
        title: "添加到歌单",
        onTap: () async {
          final musicList = logic.state.items;
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              print(music.musicName);
              // todo: 添加到播放列表
            }
          });
          logic.closeSelect();
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
