import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/box_decoration.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_playlist/view.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class MiniPlayerController extends GetxController {
  double startPosition = 0;

  Decoration createDecoration() {
    BoxDecorationData boxDecoration;
    try {
      boxDecoration = PlayerLogic.to.miniPlayerBoxDecorationData.value;
    } catch (_) {
      boxDecoration = BoxDecorationData(
          color: Get.theme.primaryColor.value, borderRadius: 34.r);
    }
    return boxDecoration.toBoxDecoration();
  }

  showPlaylistDialog() {
    SmartDialog.show(
        alignment: Alignment.bottomCenter,
        builder: (context) => const DialogPlaylist());
  }

  String? getCurrentPlayingMusicPath() {
    final currentMusic = PlayerLogic.to.playingMusic.value;
    return SDUtils.getImgPathFromMusic(currentMusic);
  }

  onMarqueeTouchDown(PointerDownEvent event) {
    startPosition = event.position.dx;
  }

  onMarqueeTouchUp(PointerUpEvent event) {
    final endPosition = event.position.dx;
    if ((endPosition - startPosition).abs() > 130.w) {
      // 距离大于50认为滑动切歌有效
      if (endPosition > startPosition) {
        PlayerLogic.to.playPrev();
      } else {
        PlayerLogic.to.playNext();
      }
    }
  }
}
