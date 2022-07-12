import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_song_sheet.dart';

import '../../../modules/ext.dart';

class DialogAddSongSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xFFF2F8FF),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h))),
      height: 450.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.h),
            child: Text(
              "添加到歌单",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff333333)),
            ),
          ),
          Divider(
            height: 0.5.h,
            color: Get.theme.primaryColor,
          ),
          _buildItem(Assets.dialogIcNewSongList, "加入播放列表", true, () {
            SmartDialog.dismiss();
          }),
          _buildItem(Assets.dialogIcNewSongList, "我喜欢", true, () {
            SmartDialog.dismiss();
          }),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 16.h, right: 16.h),
            child: ListView.separated(
                itemCount: 2,
                padding: const EdgeInsets.all(0),
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.transparent,
                    height: 10.h,
                  );
                },
                itemBuilder: (cxt, index) {
                  return ListViewItemSongSheet(
                    onItemTap: (checked) {
                      SmartDialog.dismiss();
                    },
                    index: 0,
                  );
                }),
          ))
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
