import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_playlist/logic.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_playlist.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/player_util.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class DialogPlaylist extends GetView<DialogPlaylistLogic> {
  const DialogPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => DialogPlaylistLogic());

    return Obx(() {
      final mPlayList = PlayerLogic.to.mPlayList;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Get.theme.primaryColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.h),
                topRight: Radius.circular(16.h))),
        height: 560.h,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              StreamBuilder<LoopMode>(
                stream: PlayerLogic.to.mPlayer.loopModeStream,
                builder: (context, snapshot) {
                  final loopMode = PlayerUtil.calcLoopMode(snapshot.data);
                  var header = 'shuffle_play'.tr;
                  if (loopMode == LoopMode.all) {
                    header = 'order_play'.tr;
                  } else if (loopMode == LoopMode.one) {
                    header = 'single_play'.tr;
                  }
                  return _buildItem(
                      PlayerUtil.getLoopIconFromLoopMode(loopMode),
                      "$header - ${mPlayList.length} ${'total_number_unit'.tr}",
                      () => controller.onLoopModeTap(loopMode),
                      controller.onDelAll);
                },
              ),
              Divider(
                height: 0.5.h,
                color:
                    Get.isDarkMode ? ColorMs.color737373 : ColorMs.colorCFCFCF,
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(left: 16.h, right: 16.h),
                child: ListView.separated(
                    itemCount: mPlayList.length,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(color: Colors.transparent, height: 10.h);
                    },
                    itemBuilder: (cxt, index) {
                      if (mPlayList.isEmpty) {
                        return Container();
                      }
                      final music = mPlayList[index];
                      return ListViewItemPlaylist(
                        index: index,
                        musicId: music.musicId,
                        name: music.musicName,
                        artist: music.artist,
                        onPlayTap: controller.onPlayTap,
                        onDelTap: controller.onDelTap,
                      );
                    }),
              )),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildItem(String path, String title, GestureTapCallback? onTap,
      GestureTapCallback? onRemove) {
    final color = Get.isDarkMode ? ColorMs.colorCCCCCC : ColorMs.color666666;
    final textStyle =
        Get.isDarkMode ? TextStyleMs.white_15 : TextStyleMs.black_15;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Row(
              children: [
                neumorphicButton(path, onTap,
                    width: 20,
                    height: 20,
                    iconColor: color,
                    hasShadow: false,
                    padding: const EdgeInsets.all(0)),
                SizedBox(width: 10.h),
                Expanded(child: Text(title, style: textStyle)),
                neumorphicButton(Assets.dialogIcDelete2, onRemove,
                    width: 20,
                    height: 20,
                    iconColor: color,
                    hasShadow: false,
                    padding: const EdgeInsets.all(0))
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 0.5.h, color: Get.theme.primaryColor)
          ],
        ),
      ),
    );
  }
}
