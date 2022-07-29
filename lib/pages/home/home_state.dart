import 'package:get/get.dart';

class HomeState {
  HomeState() {
    ///Initialize variables
  }

  ///选中词库Tab
  bool isSelectSongLibrary = true;

  ///选择条目模式
  var isSelect = false.obs;

  ///全选
  bool selectAll = false;

  ///选中歌曲数
  int selectSongNum = 0;

  ///底部导航栏 index
  var currentIndex = 0.obs;

  /// 0 歌曲  1 专辑  2 歌手  3 我喜欢  4 歌单  5  最近播放
  var items = <dynamic>[];
}
