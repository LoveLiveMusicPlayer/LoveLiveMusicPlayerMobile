import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_song_info.dart';
import 'package:lovelivemusicplayer/routes.dart';

class DialogMoreWithMusic extends StatefulWidget {
  final Music music;
  Function(Music)? onRemove;
  bool? isAlbum;

  DialogMoreWithMusic(
      {Key? key, required this.music, this.onRemove, this.isAlbum})
      : super(key: key);

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
    var length = 4;
    if (widget.onRemove != null) {
      length++;
    }

    if (widget.isAlbum == null || widget.isAlbum == false) {
      length++;
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
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.h),
            child: Text(
              widget.music.musicName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 17.sp,
                  color:
                      Get.isDarkMode ? Colors.white : const Color(0xff333333)),
            ),
          ),
          Divider(
            height: 0.5.h,
            color: Get.isDarkMode
                ? const Color(0xFF737373)
                : const Color(0xFFCFCFCF),
          ),
          _buildItem(Assets.dialogIcAddPlayList, "加入播放列表", true, () {
            SmartDialog.dismiss();
            PlayerLogic.to.addNextMusic(widget.music, isNext: false);
          }),
          _buildItem(Assets.dialogIcAddSongSheet, "添加到歌单", true, () {
            SmartDialog.dismiss();
            SmartDialog.compatible.show(
                widget: DialogAddSongSheet(musicList: [widget.music]),
                alignmentTemp: Alignment.bottomCenter);
          }),
          _buildItem(Assets.dialogIcSongInfo, "歌曲信息", length > 4, () {
            SmartDialog.dismiss();
            SmartDialog.compatible.show(
                widget: DialogSongInfo(music: widget.music),
                alignmentTemp: Alignment.bottomCenter);
          }),
          renderWatchAlbum(),
          renderRemoveItem()
        ],
      ),
    );
  }

  Widget renderWatchAlbum() {
    if (widget.isAlbum != null && widget.isAlbum == true) {
      return Container();
    }
    return _buildItem(Assets.dialogIcSeeAlbum, "查看专辑", widget.onRemove != null,
        () {
      SmartDialog.dismiss();
      if (album != null) {
        Get.toNamed(Routes.routeAlbumDetails, arguments: album);
      }
    });
  }

  Widget renderRemoveItem() {
    if (widget.onRemove != null) {
      return _buildItem(Assets.dialogIcDelete2, "删除歌曲", false, () {
        SmartDialog.dismiss();
        widget.onRemove!(widget.music);
      });
    }
    return Container();
  }

  ///单个条目
  Widget _buildItem(
      String path, String title, bool showLin, GestureTapCallback? onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h, right: 16.h),
      child: InkWell(
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
                    color: Get.isDarkMode
                        ? Colors.white
                        : const Color(0xFF666666)),
                SizedBox(
                  width: 10.h,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: Get.isDarkMode
                            ? Colors.white
                            : const Color(0xff666666),
                        fontSize: 15.sp),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 14.h,
            ),
            Visibility(
              visible: showLin,
              child: Divider(
                height: 0.5.h,
                color: Get.isDarkMode
                    ? const Color(0xFF737373)
                    : const Color(0xFFCFCFCF),
              ),
            )
          ],
        ),
      ),
    );
  }
}
