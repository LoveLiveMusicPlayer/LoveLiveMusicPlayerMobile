import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_more_with_music.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/listview_item_song.dart';

class DetailsBody extends StatefulWidget {
  final DetailController logic;
  final Widget buildCover;
  final List<Music> music;
  final Function(List<String>)? onRemove;
  final bool? isAlbum;
  final bool? isMenu;

  const DetailsBody({
    Key? key,
    required this.logic,
    required this.buildCover,
    required this.music,
    this.isAlbum,
    this.isMenu,
    this.onRemove,
  }) : super(key: key);

  @override
  State<DetailsBody> createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<DetailsBody> {
  var bgColor = Get.theme.primaryColor;

  @override
  void initState() {
    final bgPhoto = GlobalLogic.to.bgPhoto.value;
    if (SDUtils.checkFileExist(bgPhoto)) {
      AppUtils.getImagePalette(bgPhoto).then((color) {
        if (color != null) {
          setState(() {
            bgColor = color.withAlpha(255);
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: widget.logic.state.isSelect ? () async => false : null,
      child: Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: widget.music.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return widget.buildCover;
            } else if (index == 1) {
              return const SizedBox(height: 10);
            } else {
              final musicIndex = index - 2;
              final music = widget.music[musicIndex];
              return Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: ListViewItemSong(
                  index: musicIndex,
                  music: music,
                  checked: widget.logic.isItemChecked(musicIndex),
                  onItemTap: (index, checked) {
                    widget.logic.selectItem(index, checked);
                  },
                  onPlayNextTap: (music) async {
                    await PlayerLogic.to.addNextMusic(music);
                    SmartDialog.compatible.showToast('add_success'.tr);
                  },
                  onMoreTap: (music) {
                    SmartDialog.compatible.show(
                      widget: showDialogMoreWithMusic(music),
                      alignmentTemp: Alignment.bottomCenter,
                    );
                  },
                  onPlayNowTap: () {
                    PlayerLogic.to.playMusic(widget.music, mIndex: musicIndex);
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget showDialogMoreWithMusic(Music music) {
    if (widget.onRemove == null) {
      return DialogMoreWithMusic(music: music, isAlbum: widget.isAlbum);
    }
    return DialogMoreWithMusic(
      music: music,
      isAlbum: widget.isAlbum,
      onRemove: (music) {
        widget.onRemove!([music.musicId!]);
      },
    );
  }
}