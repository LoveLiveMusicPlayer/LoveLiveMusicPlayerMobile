import 'package:lovelivemusicplayer/models/Music.dart';

class AlbumDetailState {
  AlbumDetailState() {
    ///Initialize variables
  }

  ///选择条目模式
  bool isSelect = false;

  ///全选
  bool selectAll = false;

  var items = <Music>[];
}
