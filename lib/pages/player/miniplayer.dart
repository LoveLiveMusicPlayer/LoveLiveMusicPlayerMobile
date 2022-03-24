import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/test/logic.dart';
import 'package:marquee_text/marquee_text.dart';
import '../../models/Music.dart';
import '../../modules/ext.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  var logic = Get.find<TestLogic>();

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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
                GestureDetector(
                  onTap: () => widget.onTap(),
                  child: Row(
                    children: [
                      SizedBox(width: 6.w),
                      Obx(() => getCover(
                          logic.musicList.value, logic.currentIndex.value))
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => CarouselSlider(
                          items: refreshList(logic.musicList.value),
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
                ),
                SizedBox(width: 10.w),
                const Icon(Icons.play_arrow,
                    color: Color(0xff333333), size: 30),
                SizedBox(width: 20.w),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.music_note, color: Color(0xff333333)),
                ),
                SizedBox(width: 20.w),
              ],
            ),
          ),
          Divider(color: colorTheme.background, height: 1),
          SizedBox(height: 140.h),
        ],
      ),
      decoration: BoxDecoration(
        color: colorTheme.background,
        borderRadius: BorderRadius.circular(34),
      ),
    );
  }

  List<Widget> refreshList(List<Music> musicList) {
    scrollList.clear();
    if (musicList.isEmpty) {
      scrollList.add(const MarqueeText(
          text: TextSpan(text: "暂无歌曲"),
          style: TextStyle(fontSize: 15, color: Color(0xFF333333), height: 1.3),
          speed: 15));
      return scrollList;
    }
    musicList.forEach((element) {
      scrollList.add(MarqueeText(
          text: TextSpan(text: element.name),
          style: const TextStyle(
              fontSize: 15, color: Color(0xFF333333), height: 1.3),
          speed: 15));
    });
    return scrollList;
  }

  Widget getCover(List<Music> musicList, int index) {
    if (musicList.isEmpty) {
      return showImg("assets/thumb/XVztg3oXmX4.jpg", radius: 50, width: 50.h, height: 50.h, hasShadow: false);
    } else {
      return showImg(logic.musicList[logic.currentIndex.value].cover,
          radius: 50, width: 50.h, height: 50.h, hasShadow: false);
    }
  }
}
