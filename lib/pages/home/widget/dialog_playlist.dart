import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_playlist.dart';

class DialogPlaylist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xFFF2F8FF),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h))),
      height: 560.h,
      child: Column(
        children: [
          _buildItem(Assets.playerPlayShuffle,
              "随机播放(${PlayerLogic.to.mPlayList.length})", true, () {}),
          Divider(
            height: 0.5.h,
            color: const Color(0xffe7f2ff),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 16.h, right: 16.h),
            child: ListView.separated(
                itemCount: PlayerLogic.to.mPlayList.length,
                padding: const EdgeInsets.all(0),
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.transparent,
                    height: 10.h,
                  );
                },
                itemBuilder: (cxt, index) {
                  if (PlayerLogic.to.mPlayList.isNotEmpty) {
                    return ListViewItemPlaylist(
                      index: index,
                      name: PlayerLogic.to.mPlayList[index].name ?? "",
                      artist: PlayerLogic.to.mPlayList[index].artist ?? "",
                      onTap: (index) {
                        // todo
                        // PlayerLogic.to.mPlayList.removeAt(index);
                      },
                    );
                  } else {
                    return Container();
                  }
                }),
          )),
        ],
      ),
    );
  }

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
                ),
                touchIconByAsset(
                    path: Assets.playerPlayShuffle,
                    onTap: () {},
                    width: 16.h,
                    height: 16.h,
                    color: const Color(0xFF999999))
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
