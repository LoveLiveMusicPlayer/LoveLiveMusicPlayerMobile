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
  MiniPlayer({Key? key, required this.onTap})
      : super(key: key);
  final GestureTapCallback onTap;

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
        ));
  }

  Widget miniCover() {
    return GestureDetector(
      onTap: () => widget.onTap(),
      child: GetBuilder<MainLogic>(builder: (logic) {
        LogUtil.e(logic.state.playingMusic.cover);
        return Row(
          children: [SizedBox(width: 6.w), showImg(logic.state.playingMusic.cover, radius: 50, width: 50, height: 50, hasShadow: false)],
        );
      }),
    );
  }

  Widget marqueeMusicName() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GetBuilder<MainLogic>(
            id: "miniPlayer",
            builder: (logic) {
              final isCanScroll = logic.state.isCanMiniPlayerScroll;
              return CarouselSlider(
                  items: refreshList(logic.state.playList, logic.state.playingMusic),
                  carouselController: sliderController,
                  options: CarouselOptions(
                      height: 20.h,
                      viewportFraction: 1.0,
                      scrollPhysics: isCanScroll
                          ? const PageScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        if (isCanScroll) {
                          logic.changeMusic(index);
                        }
                      })
              );
            },
          )
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
    int count = -1;
    musicList.forEach((element) {
      count++;
      scrollList.add(MarqueeText(
          text: TextSpan(text: element.name),
          style: const TextStyle(
              fontSize: 15, color: Color(0xFF333333), height: 1.3),
          speed: 15));
      if (element.uid == currentMusic.uid) {
        slidePage(count);
      }
    });
    return scrollList;
  }

  slidePage(int count) async {
    await Future.delayed(const Duration(milliseconds: 200));
    sliderController.jumpToPage(count);
  }
}
