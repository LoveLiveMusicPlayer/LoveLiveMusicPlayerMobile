import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

const List<String> images = [];

class ExampleHorizontal extends StatelessWidget {
  const ExampleHorizontal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const pagination = SwiperPagination(
        builder:
            DotSwiperPaginationBuilder(activeColor: Colors.red, space: 5.0));
    return Container(
        height: 120,
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Swiper(
            itemBuilder: (context, index) {
              final image = images[index];
              return Image.asset(
                image,
                fit: BoxFit.cover,
              );
            },
            indicatorLayout: PageIndicatorLayout.COLOR,
            autoplay: true,
            itemCount: images.length,
            pagination: pagination,
            control: const SwiperControl(color: Colors.transparent),
          ),
        ));
  }
}
