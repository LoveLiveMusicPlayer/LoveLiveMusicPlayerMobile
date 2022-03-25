import '../../models/music_Item.dart';

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

  ///列表数据
  List<MusicItem> items = [MusicItem(titlle: "",checked: false),
    MusicItem(titlle: "",checked: false),
    MusicItem(titlle: "",checked: false),
    MusicItem(titlle: "",checked: false),
    MusicItem(titlle: "",checked: false),
    MusicItem(titlle: "",checked: false)];

}
