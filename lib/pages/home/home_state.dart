import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/music.dart';

class HomeState {
  HomeState() {
    ///Initialize variables
  }

  ///选中词库Tab
  bool isSelectSongLibrary = true;

  ///选择模式(0: 常规, 1: 条目, 2: 搜索)
  var selectMode = 0.obs;

  ///全选
  bool selectAll = false;

  ///底部导航栏 index
  var currentIndex = 0.obs;

  /// 0 歌曲  1 专辑  2 歌手  3 我喜欢  4 歌单  5  最近播放
  var items = <dynamic>[];

  /// 为了快速筛选，把数据库原始数据备份一份，等取消搜索后恢复
  var oldMusicList = <Music>[];
  var oldLoveList = <Music>[];
  var oldRecentList = <Music>[];

  /// 搜索框软键盘输入控制器
  final searchControl = TextEditingController();
}
