import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/Music.dart';
import '../../test/logic.dart';

class PlayerHeader extends StatelessWidget {
  final Function onTap;
  var logic = Get.find<TestLogic>();

  PlayerHeader({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => onTap(),
            iconSize: 32,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF999999),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Obx(() => getTitle(logic.musicList.value, logic.currentIndex.value)),
                Obx(() => getSinger(logic.musicList.value, logic.currentIndex.value)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget getTitle(List<Music> musicList, int index) {
    if (musicList.isEmpty) {
      return const Text(
        "暂无歌曲",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Color(0xFF333333), fontSize: 15),
        maxLines: 1,
      );
    }
    return Text(
      musicList[index].name,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Color(0xFF333333), fontSize: 15),
      maxLines: 1,
    );
  }

  Widget getSinger(List<Music> musicList, int index) {
    if (musicList.isEmpty) {
      return const Text(
        "",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Color(0xFF333333), fontSize: 12),
        maxLines: 1,
      );
    }
    return Text(
      musicList[index].singer,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
      maxLines: 1,
    );
  }
}