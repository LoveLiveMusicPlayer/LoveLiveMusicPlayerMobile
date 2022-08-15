import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_playlist.dart';

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
              var header = "随机播放";
              if (index == 1) {
                header = "顺序循环";
              } else if (index == 2) {
                header = "单曲循环";
              }
              return _buildItem(
                  icons[index], "$header - 共${mPlayList.length}首", true, () {
                final currentIndex = PlayerLogic.loopModes.indexOf(loopMode);
                final nextIndex =
                    (currentIndex + 1) % PlayerLogic.loopModes.length;
                PlayerLogic.to.changeLoopMode(nextIndex);
              });
            },
          ),
          Divider(
            height: 0.5.h,
            color: Get.isDarkMode
                ? const Color(0xFF737373)
                : const Color(0xFFCFCFCF),
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
                      name: mPlayList[index].musicName,
                      artist: mPlayList[index].artist,
                      onPlayTap: (index) {
                        if (GlobalLogic.to.isHandlePlay) {
                          return;
                        }
                        GlobalLogic.to.isHandlePlay = true;
                        final musicIds = <String>[];
                        for (var playListMusic in mPlayList) {
                          musicIds.add(playListMusic.musicId);
                        }
                        DBLogic.to.musicDao
                            .findMusicsByMusicIds(musicIds)
                            .then((musicList) {
                          PlayerLogic.to.playMusic(musicList, index: index);
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
                    onTap: onTap,
                    width: 16.h,
                    height: 16.h,
                    color: Get.isDarkMode
                        ? const Color(0xFFCCCCCC)
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
                            : const Color(0xff333333),
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
                color: Get.theme.primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
