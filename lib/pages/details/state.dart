import 'package:lovelivemusicplayer/models/music.dart';

class DetailState {
  DetailState() {
    ///Initialize variables
  }

  String title = "";

  ///选择条目模式
  bool isSelect = false;

  ///全选
  bool selectAll = false;

  var items = <Music>[];
}
