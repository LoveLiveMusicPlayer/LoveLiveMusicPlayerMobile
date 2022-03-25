import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/main/logic.dart';
import '../../../models/Music.dart';
import '../../../modules/ext.dart';

class PlayerHeader extends StatelessWidget {
  final GestureTapCallback onTap;
  var logic = Get.find<MainLogic>();

  PlayerHeader({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: <Widget>[
          /// 折叠向下箭头
          materialButton(Icons.keyboard_arrow_down, onTap,
              width: 32,
              height: 32,
              iconSize: 20,
              radius: 6,
              iconColor: const Color(0xFF999999)),

          /// 曲名 + 歌手
          Expanded(
            child: Obx(() => Column(
                  children: <Widget>[
                    getTitle(logic.musicList.value, logic.playingIndex.value),
                    getSinger(logic.musicList.value, logic.playingIndex.value),
                  ],
                )),
          ),

          /// 更多功能
          materialButton(Icons.more_horiz, () => {},
              width: 32,
              height: 32,
              iconSize: 18,
              radius: 6,
              iconColor: const Color(0xFF999999)),
        ],
      ),
    );
  }

  Widget getTitle(List<Music> musicList, int index) {
    if (musicList.isEmpty || musicList[index].name == null) {
      return Text(
        "暂无歌曲",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: const Color(0xFF333333), fontSize: 15.sp),
        maxLines: 1,
      );
    }
    return Text(
      musicList[index].name!,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: const Color(0xFF333333), fontSize: 15.sp),
      maxLines: 1,
    );
  }

  Widget getSinger(List<Music> musicList, int index) {
    if (musicList.isEmpty || musicList[index].singer == null) {
      return Text(
        "",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: const Color(0xFF333333), fontSize: 12.sp),
        maxLines: 1,
      );
    }
    return Text(
      musicList[index].singer!,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: const Color(0xFF999999), fontSize: 12.sp),
      maxLines: 1,
    );
  }
}
