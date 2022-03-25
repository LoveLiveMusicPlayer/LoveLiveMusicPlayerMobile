class Song_libraryState {
  Song_libraryState() {
    ///Initialize variables
  }

  ///歌曲条数
  int songNum = 0;

  ///选择条目模式
  bool isSelect = false;

  ///全选
  bool selectAll = false;

  ///选中歌曲数
  int selectSongNum = 0;

  ///列表数据
  List<String> items = ["xxx","xxx","xx"];
}
