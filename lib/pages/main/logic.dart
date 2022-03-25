import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/Music.dart';
import '../../models/music_Item.dart';
import '/network/http_request.dart';

import 'state.dart';

class MainLogic extends GetxController {
  final MainState state = MainState();

  getData() {
    Network.get(
        'https://inventory.scionedev.ilabservice.cloud/api/labbase/v1/company/all?account=17826808739&type=saas',
        success: (w) {
      if (w != null && w is List) {
        for (var element in w) {
          LogUtil.e(element);
        }
      }
    });
  }

  selectSongLibrary(bool value) {
    state.isSelectSongLibrary = value;
    refresh();
  }

  openSelect() {
    state.isSelect = !state.isSelect;
    refresh();
  }

  addItem(List<MusicItem> data) {
    state.items.addAll(data);
    refresh();
  }

  selectAll(bool checked) {
    for (var element in state.items) {
      element.checked = checked;
    }
    refresh();
  }

  selectItem(int index, bool checked) {
    state.items[index].checked = checked;
    refresh();
  }

  isItemChecked(int index) {
    return state.items[index].checked;
  }

  int getCheckedSong() {
    int num = 0;
    for (var element in state.items) {
      if (element.checked) {
        num++;
      }
    }
    return num;
  }

  playPrevMusic(List<Music> musicList, int index) {
    if (musicList.isEmpty) {
      return;
    }
    if (index == 0) {
      playingIndex.value = musicList.length - 1;
    } else {
      playingIndex.value = index - 1;
    }
  }

  playNextMusic(List<Music> musicList, int index) {
    if (musicList.isEmpty) {
      return;
    }
    if (index == musicList.length - 1) {
      playingIndex.value = 0;
      playingMusic.value = musicList[0];
    } else {
      playingIndex.value = index + 1;
      playingMusic.value = musicList[0];
    }
  }

  togglePlay() {

  }

  ///-------------------------------
  var image = "".obs;
  var currentIndex = 0.obs;
  var musicList = <Music>[].obs;

  var playingIndex = 0.obs;
  var playingMusic = Music().obs ;

  var picPath = "";

  Future<void> getFlac() async {
    const filePath = "LoveLive/Cover_1.jpg";
    Directory appDocDir = await getApplicationDocumentsDirectory();
    picPath = appDocDir.path + Platform.pathSeparator + filePath;
    LogUtil.e(picPath);
    image.value = picPath;
  }

  @override
  Future<void> onReady() async {
    await getFlac();
    musicList.add(Music(name: "START!! True dreams", cover: picPath, singer: "Liella!", time: "03:42"));
    musicList.add(Music(name: "START!! True dreams1212121212", cover: picPath, singer: "Liella!", time: "03:42"));
    musicList.add(Music(name: "START!!", cover: picPath, singer: "Liella!", time: "03:42"));

    playingMusic.value = musicList.value[0];
    super.onReady();
  }
}
