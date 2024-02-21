import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_song_info.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';

class DialogMoreWithMusic extends StatefulWidget {
  final Music music;
  final Function(Music)? onRemove;
  final Function()? onClosePanel;
  final bool? isAlbum;
  final bool? isPlayer;
  final Function(bool)? changeLoveStatusCallback;

  const DialogMoreWithMusic(
      {super.key,
      required this.music,
      this.onRemove,
      this.isAlbum,
      this.isPlayer,
      this.onClosePanel,
      this.changeLoveStatusCallback});

  @override
  State<DialogMoreWithMusic> createState() => _DialogMoreWithMusicState();
}

class _DialogMoreWithMusicState extends State<DialogMoreWithMusic> {
  Album? album;

  @override
  void initState() {
    super.initState();
    DBLogic.to.findAlbumById(widget.music.albumId!).then((mAlbum) {
      album = mAlbum;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var length = 5;
    final array = <Widget>[];

    array.add(renderTitle());
    array.add(renderDivider(0));
    array.add(renderAddPlayList());
    array.add(renderDivider());
    array.add(renderAddMenu());
    array.add(renderDivider());
    array.add(renderMusicInfo());
    array.add(renderDivider());
    array.add(renderShareMusic());

    if (widget.onRemove != null) {
      length++;
      array.add(renderDivider());
      array.add(renderRemoveItem());
    }
    if (SDUtils.allowEULA) {
      length++;
      array.add(renderDivider());
      array.add(renderSearchInMoeGirl());
    }
    if (widget.isAlbum == null || widget.isAlbum == false) {
      length++;
      array.add(renderDivider());
      array.add(renderWatchAlbum());
    }
    if (widget.isPlayer != null || widget.isPlayer == true) {
      length++;
      array.add(renderDivider());
      array.add(renderResearchLyric());
    }
    return Container(
      height: length * 55.h,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          boxShadow: [
            BoxShadow(
                color: Get.theme.primaryColor, blurRadius: 4, spreadRadius: 4)
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h))),
      child: Column(children: array),
    );
  }

  /// 歌曲标题
  Widget renderTitle() {
    return Padding(
      padding: EdgeInsets.all(12.h),
      child: Text(widget.music.musicName!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.isDarkMode ? TextStyleMs.white_17 : TextStyleMs.black_17),
    );
  }

  /// 加入播放列表
  Widget renderAddPlayList() {
    return _buildItem(Assets.dialogIcAddPlayList, 'add_to_playlist'.tr,
        () async {
      SmartDialog.compatible.dismiss();
      await PlayerLogic.to.addNextMusic(widget.music, isNext: false);
      SmartDialog.compatible.showToast('add_success'.tr);
    });
  }

  /// 添加到歌单
  Widget renderAddMenu() {
    return _buildItem(Assets.dialogIcAddSongSheet, 'add_to_menu'.tr, () {
      SmartDialog.compatible.dismiss();
      SmartDialog.compatible.show(
          widget: DialogAddSongSheet(
              musicList: [widget.music],
              changeLoveStatusCallback: widget.changeLoveStatusCallback),
          alignmentTemp: Alignment.bottomCenter);
    });
  }

  /// 歌曲信息
  Widget renderMusicInfo() {
    return _buildItem(Assets.dialogIcSongInfo, 'music_info'.tr, () {
      SmartDialog.compatible.dismiss();
      SmartDialog.compatible.show(
          widget: DialogSongInfo(music: widget.music),
          alignmentTemp: Alignment.bottomCenter);
    });
  }

  /// 在萌娘百科搜索
  Widget renderSearchInMoeGirl() {
    return _buildItem(Assets.drawerDrawerInspect, 'search_in_moe_girl'.tr, () {
      SmartDialog.compatible.dismiss();
      AppUtils.vibrate();
      SmartDialog.compatible.show(
          widget: TwoButtonDialog(
        title: "search_at_moe".tr,
        msg: "moe_address_error".tr,
        onConfirmListener: () {
          Get.toNamed(Routes.routeMoeGirl, arguments: widget.music.musicName!);
        },
      ));
    });
  }

  /// 查看专辑
  Widget renderWatchAlbum() {
    if (widget.isAlbum != null && widget.isAlbum == true) {
      return Container();
    }
    return _buildItem(Assets.dialogIcSeeAlbum, 'view_album'.tr, () {
      SmartDialog.compatible.dismiss();
      widget.onClosePanel?.call();
      if (album != null) {
        Get.toNamed(Routes.routeAlbumDetails, arguments: album, id: 1);
      }
    });
  }

  /// 删除歌曲
  Widget renderRemoveItem() {
    if (widget.onRemove != null) {
      return _buildItem(Assets.dialogIcDelete2, 'remove_music'.tr, () {
        SmartDialog.compatible.dismiss();
        widget.onRemove!(widget.music);
      });
    }
    return Container();
  }

  /// 分享歌曲
  Widget renderShareMusic() {
    return _buildItem(Assets.drawerDrawerShare, 'share_music'.tr, () {
      SmartDialog.compatible.dismiss();
      AppUtils.shareQQ(music: widget.music);
    });
  }

  /// 重新搜索歌词
  Widget renderResearchLyric() {
    if (widget.isPlayer == null || widget.isPlayer == false) {
      return Container();
    }
    return _buildItem(Assets.drawerDrawerReset, 'search_lyric'.tr, () {
      PlayerLogic.to.getLrc(true);
      SmartDialog.compatible.dismiss();
    });
  }

  /// 绘制分割线
  Widget renderDivider([int padding = 16]) {
    return Padding(
      padding: EdgeInsets.only(left: padding.h, right: padding.h),
      child: Divider(
        height: 0.5.h,
        color: Get.isDarkMode ? ColorMs.color737373 : ColorMs.colorCFCFCF,
      ),
    );
  }

  ///单个条目
  Widget _buildItem(String path, String title, GestureTapCallback? onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h, right: 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 14.h,
            ),
            Row(
              children: [
                touchIconByAsset(
                    path: path,
                    onTap: () {},
                    width: 16.h,
                    height: 16.h,
                    color: Get.isDarkMode ? Colors.white : ColorMs.color666666),
                SizedBox(
                  width: 10.h,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: Get.isDarkMode
                        ? TextStyleMs.white_15
                        : TextStyleMs.lightBlack_15,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 14.h,
            )
          ],
        ),
      ),
    );
  }
}
