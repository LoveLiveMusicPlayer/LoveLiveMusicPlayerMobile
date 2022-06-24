import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';

import '../../../modules/ext.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';

class DialogMore extends StatelessWidget {
  final Music music;
  const DialogMore({Key? key, required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280.h,
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xFFF2F8FF),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h))),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.h),
            child: Text(
              music.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17.sp, color: const Color(0xff333333)),
            ),
          ),
          Divider(
            height: 0.5.h,
            color: Get.theme.primaryColor,
          ),
          _buildItem(Assets.dialogIcAddPlayList, "加入播放列表", true, () {
            SmartDialog.dismiss();
          }),
          _buildItem(Assets.dialogIcAddSongSheet, "添加到歌单", true, () {
            SmartDialog.dismiss();
            SmartDialog.compatible.show(
                widget: DialogAddSongSheet(),
                alignmentTemp: Alignment.bottomCenter);
          }),
          _buildItem(Assets.dialogIcSongInfo, "歌曲信息", true, () {
            SmartDialog.dismiss();
          }),
          _buildItem(Assets.dialogIcSeeAlbum, "查看专辑", true, () {
            SmartDialog.dismiss();
          }),
        ],
      ),
    );
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
                    color: const Color(0xFF666666)),
                SizedBox(
                  width: 10.h,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: const Color(0xff333333), fontSize: 15.sp),
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
                color: Get.theme.primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
