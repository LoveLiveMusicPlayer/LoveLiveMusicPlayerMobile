import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marquee_text/marquee_text.dart';
import '../../models/Music.dart';
import '../../modules/ext.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../main/logic.dart';

class MiniPlayer extends StatefulWidget {
  MiniPlayer({Key? key, required this.onTap, required this.onChangeMusic})
      : super(key: key);
  final Function onTap;
  final Function(int index, CarouselPageChangedReason reason) onChangeMusic;

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final scrollList = <Widget>[];
  var logic = Get.find<MainLogic>();

  CarouselController sliderController = CarouselController();

  @override
  Widget build(BuildContext context) {

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8FF),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        children: [
          Container(
            height: 60.h,
            margin: EdgeInsets.only(left: 16.w, right: 16.w),
            decoration: BoxDecoration(
                color: const Color(0xFFEBF3FE),
                borderRadius: BorderRadius.circular(34)),
            child: Row(
              children: [
                /// 迷你封面
                miniCover(),
                SizedBox(width: 6.w),
                /// 滚动歌名
                marqueeMusicName(),
                SizedBox(width: 10.w),
                /// 播放按钮
                touchIcon(Icons.play_arrow, () => {}, size: 30.w),
                SizedBox(width: 20.w),
                /// 播放列表按钮
                touchIcon(Icons.music_note, () => {}),
                SizedBox(width: 20.w),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget miniCover() {
    return GestureDetector(
      onTap: () => widget.onTap(),
      child: Row(
        children: [
          SizedBox(width: 6.w),
          Obx(() => getCover(logic.playingMusic.value))
        ],
      ),
    );
  }

  Widget marqueeMusicName() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => CarouselSlider(
              items:
                  refreshList(logic.musicList.value, logic.playingMusic.value),
              carouselController: sliderController,
              options: CarouselOptions(
                  height: 20.h,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) =>
                      {widget.onChangeMusic(index, reason)},
                  scrollDirection: Axis.horizontal)))
        ],
      ),
    );
  }

  List<Widget> refreshList(List<Music> musicList, Music currentMusic) {
    scrollList.clear();
    if (musicList.isEmpty) {
      scrollList.add(const MarqueeText(
          text: TextSpan(text: "暂无歌曲"),
          style: TextStyle(fontSize: 15, color: Color(0xFF333333), height: 1.3),
          speed: 15));
      return scrollList;
    }
    LogUtil.e(currentMusic.name);
    int count = -1;
    musicList.forEach((element) {
      count++;
      scrollList.add(MarqueeText(
          text: TextSpan(text: element.name),
          style: const TextStyle(
              fontSize: 15, color: Color(0xFF333333), height: 1.3),
          speed: 15));
      if (element.uid == currentMusic.uid) {
        setPlayedName(count);
      }
    });
    return scrollList;
  }

  setPlayedName(int index) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    sliderController.jumpToPage(index);
  }

  Widget getCover(Music? music) {
    if (music == null || music.cover == null) {
      return showImg("assets/thumb/XVztg3oXmX4.jpg",
          radius: 50, width: 50.h, height: 50.h, hasShadow: false);
    } else {
      return showImg(music.cover!,
          radius: 50, width: 50.h, height: 50.h, hasShadow: false);
    }
  }
}
