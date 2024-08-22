import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/group.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DriveModeLogic extends GetxController {
  @override
  void onInit() {
    super.onInit();
    WakelockPlus.enable();
  }

  Future<void> playMusicWithListFetcher(
      Future<List<Music>> Function() fetchList) async {
    GlobalLogic.to.currentGroup.value = GroupKey.groupAll.getName();
    await DBLogic.to.findAllListByGroup(GroupKey.groupAll.getName());

    final musicList = await fetchList();

    if (musicList.isEmpty) {
      SmartDialog.showToast('no_songs'.tr);
      return;
    }

    PlayerLogic.to.playMusic(musicList);
  }

  playILoveMusic() {
    playMusicWithListFetcher(() async => GlobalLogic.to.loveList);
  }

  playHistoryMusic() {
    playMusicWithListFetcher(() async => GlobalLogic.to.recentList);
  }

  changeLoopMode(LoopMode loopMode) {
    final currentIndex = PlayerLogic.loopModes.indexOf(loopMode);
    final nextIndex = (currentIndex + 1) % PlayerLogic.loopModes.length;
    PlayerLogic.to.changeLoopMode(nextIndex);
  }

  togglePlay(bool isPlayingNow, ProcessingState? playerState) {
    if (isPlayingNow) {
      PlayerLogic.to.mPlayer.pause();
    } else if (playerState == ProcessingState.completed) {
      final indices = PlayerLogic.to.mPlayer.effectiveIndices;
      if (indices != null && indices.isNotEmpty) {
        PlayerLogic.to.mPlayer.seek(Duration.zero, index: indices.first);
      }
    } else {
      PlayerLogic.to.mPlayer.play();
    }
  }

  toggleLove() {
    PlayerLogic.to.toggleLove();
  }

  @override
  void onClose() {
    WakelockPlus.disable();
    super.onClose();
  }
}
