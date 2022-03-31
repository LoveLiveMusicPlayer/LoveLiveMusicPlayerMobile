import '../../models/music_Item.dart';

class AlbumDetailsState {
  AlbumDetailsState() {
    ///Initialize variables
  }

  ///选中词库Tab
  bool isSelectSongLibrary = true;

  ///选择条目模式
  bool isSelect = false;

  ///全选
  bool selectAll = false;

  ///列表数据
  List<MusicItem> items = [
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false),
    MusicItem(titlle: "", checked: false)
  ];
}
