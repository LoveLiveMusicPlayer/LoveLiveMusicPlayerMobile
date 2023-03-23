import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_playlist.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class DialogPlaylist extends StatefulWidget {
  const DialogPlaylist({Key? key}) : super(key: key);

  @override
  State<DialogPlaylist> createState() => _DialogPlaylistState();
}

class _DialogPlaylistState extends State<DialogPlaylist> {
  var mPlayList = PlayerLogic.to.mPlayList;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h))),
      height: 560.h,
      child: Column(
        children: [
          StreamBuilder<LoopMode>(
            stream: PlayerLogic.to.mPlayer.loopModeStream,
            builder: (context, snapshot) {
              var loopMode = snapshot.data ?? LoopMode.off;
              const icons = [
                Assets.playerPlayShuffle,
                Assets.playerPlayRecycle,
                Assets.playerPlaySingle
              ];
              if (loopMode == LoopMode.all &&
                  PlayerLogic.to.mPlayer.shuffleModeEnabled) {
                loopMode = LoopMode.off;
              }
              final index = PlayerLogic.loopModes.indexOf(loopMode);
              var header = 'shuffle_play'.tr;
              if (index == 1) {
                header = 'order_play'.tr;
              } else if (index == 2) {
                header = 'single_play'.tr;
              }
              return _buildItem(
                  icons[index],
                  "$header - ${mPlayList.length} ${'total_number_unit'.tr}",
                  true, () {
                final currentIndex = PlayerLogic.loopModes.indexOf(loopMode);
                final nextIndex =
                    (currentIndex + 1) % PlayerLogic.loopModes.length;
                PlayerLogic.to.changeLoopMode(nextIndex);
              }, () {
                mPlayList.removeRange(0, mPlayList.length);
                setState(() {});
                PlayerLogic.to.removeAllMusics();
              });
            },
          ),
          Divider(
            height: 0.5.h,
            color: Get.isDarkMode ? ColorMs.color737373 : ColorMs.colorCFCFCF,
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 16.h, right: 16.h),
            child: ListView.separated(
                itemCount: mPlayList.length,
                padding: EdgeInsets.only(
                    left: 0.w, top: 8.h, right: 0.w, bottom: 8.h),
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.transparent,
                    height: 10.h,
                  );
                },
                itemBuilder: (cxt, index) {
                  if (mPlayList.isNotEmpty) {
                    return ListViewItemPlaylist(
                      index: index,
                      musicId: mPlayList[index].musicId,
                      name: mPlayList[index].musicName,
                      artist: mPlayList[index].artist,
                      onPlayTap: (index) {
                        SmartDialog.compatible.showLoading(msg: "loading".tr);
                        List<String> idList = [];
                        for (var element in mPlayList) {
                          idList.add(element.musicId);
                        }
                        DBLogic.to.findMusicByMusicIds(idList).then((musicList) {
                          PlayerLogic.to.playMusic(musicList, index: index);
                          Future.delayed(const Duration(milliseconds: 1000)).then((value) {
                            SmartDialog.compatible.dismiss(status: SmartStatus.loading);
                          });
                        });
                      },
                      onDelTap: (index) {
                        mPlayList.removeAt(index);
                        setState(() {});
                        PlayerLogic.to.removeMusic(index);
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

  Widget _buildItem(String path, String title, bool showLin,
      GestureTapCallback? onTap, GestureTapCallback? onRemove) {
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
                    onTap: onTap,
                    width: 16.h,
                    height: 16.h,
                    color: Get.isDarkMode
                        ? ColorMs.colorCCCCCC
                        : ColorMs.color666666),
                SizedBox(
                  width: 10.h,
                ),
                Expanded(
                  child: Text(title,
                      style: Get.isDarkMode
                          ? TextStyleMs.white_15
                          : TextStyleMs.black_15),
                ),
                touchIconByAsset(
                    path: Assets.dialogIcDelete2,
                    onTap: onRemove,
                    width: 16.h,
                    height: 16.h,
                    color: Get.isDarkMode
                        ? ColorMs.colorCCCCCC
                        : ColorMs.color666666),
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
