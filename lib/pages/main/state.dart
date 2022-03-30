import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Music.dart';

import '../../models/music_Item.dart';
import '../../utils/sd_utils.dart';

class MainState {
  MainState() {
    ///Initialize variables
  }

  ///选中词库Tab
  bool isSelectSongLibrary = true;

  ///选择条目模式
  bool isSelect = false;

  ///全选
  bool selectAll = false;

  ///选中歌曲数
  int selectSongNum = 0;

  ///底部导航栏 index
  int currentIndex = 0;

  ///列表数据
  List<MusicItem> items = [
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false)
  ];

  var isPlaying = false;

  Music playingMusic = Music();
  bool isCanMiniPlayerScroll = true;
  int lrcType = 0; // 0:原文; 1:翻译; 2:罗马音

  String jpLrc = "";
  String zhLrc = "";
  String romaLrc = "";

  List<Music> playList = [
    Music(
      uid: "1",
      name: "START!! True dreams",
      coverPath: SDUtils.path + "LoveLive/Cover_1.jpg",
      artist: "Liella!",
      totalTime: "03:42",
      isPlaying: true,
      jpUrl:
          "JP/LoveLive/Liella!/%E5%8A%A8%E7%94%BB/%5B2021.07.21%5D%20Liella!%20-%20START!!%20True%20dreams/01.%20START!!%20True%20dreams.lrc",
      zhUrl:
          "ZH/LoveLive/Liella!/%E5%8A%A8%E7%94%BB/%5B2021.07.21%5D%20Liella!%20-%20START!!%20True%20dreams/01.%20START!!%20True%20dreams.lrc",
      romaUrl:
          "ROMA/LoveLive/Liella!/%E5%8A%A8%E7%94%BB/%5B2021.07.21%5D%20Liella!%20-%20START!!%20True%20dreams/01.%20START!!%20True%20dreams.lrc",
    ),
    Music(
      uid: "2",
      name: "HOT PASSION!!",
      coverPath: SDUtils.path + "LoveLive/Cover_2.jpg",
      artist: "Sunny Passion",
      totalTime: "04:18",
    ),
    Music(
      uid: "3",
      name: "常夏☆サンシャイン",
      coverPath: SDUtils.path + "LoveLive/Cover_3.jpg",
      artist: "Liella!",
      totalTime: "04:42",
    )
  ];
}
