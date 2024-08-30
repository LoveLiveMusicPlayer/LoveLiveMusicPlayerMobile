import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/utils/player_util.dart';

class DialogPlaylistLogic extends GetxController {
  onLoopModeTap(LoopMode loopMode) {
    PlayerUtil.changeLoopModeByLoopTap(loopMode);
  }

  onDelAll() {
    PlayerLogic.to.mPlayList.clear();
    PlayerLogic.to.removeAllMusics();
  }

  onPlayTap(int index) {
    SmartDialog.showLoading(msg: "loading".tr);
    List<String> idList = [];
    for (var element in PlayerLogic.to.mPlayList) {
      idList.add(element.musicId);
    }
    DBLogic.to.findMusicByMusicIds(idList).then((musicList) {
      PlayerLogic.to.playMusic(musicList, mIndex: index);
    });
  }

  onDelTap(int index) {
    PlayerLogic.to.removeMusic(index);
  }
}
