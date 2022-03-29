import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lovelivemusicplayer/pages/main/widget/dialog_add_song_sheet.dart';

import '../../../modules/ext.dart';

class DialogMore extends StatelessWidget {
  const DialogMore({Key? key}) : super(key: key);

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
              "だから僕らは鳴らすんだ！",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17.sp, color: const Color(0xff333333)),
            ),
          ),
          Divider(
            height: 0.5.h,
            color: const Color(0xFFEAF4FF),
          ),
          _buildItem("assets/dialog/ic_add_play_list.svg","加入播放列表",true,(){
            SmartDialog.dismiss();
          }),
          _buildItem("assets/dialog/ic_add_song_sheet.svg","添加到歌单",true,(){
            SmartDialog.dismiss();
            SmartDialog.show(widget: DialogAddSongSheet(),alignmentTemp:Alignment.bottomCenter);
          }),
          _buildItem("assets/dialog/ic_song_info.svg","歌曲信息",true,(){
            SmartDialog.dismiss();
          }),
          _buildItem("assets/dialog/ic_see_album.svg","查看专辑",true,(){
            SmartDialog.dismiss();
          }),
        ],
      ),
    );
  }

  ///单个条目
  Widget _buildItem(String path,String title,bool showLin,GestureTapCallback? onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h, right: 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 14.h,),
            Row(
              children: [
                touchIconByAsset(path: path, onTap: () {},
                    width: 16.h, height: 16.h, color: const Color(0xFF666666)),
                SizedBox(width: 10.h,),
                Expanded(
                  child: Text(
                    title,
                    style:
                        TextStyle(color: const Color(0xff333333), fontSize: 15.sp),
                  ),
                )
              ],
            ),
            SizedBox(height: 14.h,),
            Visibility(
              visible: showLin,
              child: Divider(
                height: 0.5.h,
                color: const Color(0xFFEAF4FF),
              ),
            )
          ],
        ),
      ),
    );
  }
}
