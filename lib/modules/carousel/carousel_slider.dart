import 'package:carousel_slider/carousel_slider.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';

class CarouselPlayer extends StatelessWidget {
  final List<Widget> listItems;
  final CarouselController sliderController;
  final bool isCanScroll;

  const CarouselPlayer(
      {Key? key,
      required this.listItems,
      required this.sliderController,
      required this.isCanScroll})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        items: listItems,
        carouselController: sliderController,
        options: CarouselOptions(
            height: 20.h,
            viewportFraction: 1.0,
            scrollPhysics: isCanScroll
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              final isController = reason == CarouselPageChangedReason.controller;
              if (isCanScroll) {
                PlayerLogic.to.changePlayIndex(isController, index);
              }
            }));
  }
}
