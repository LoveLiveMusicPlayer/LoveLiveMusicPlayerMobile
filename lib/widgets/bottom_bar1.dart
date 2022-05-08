import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  var mIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    mIndex = handlePage(HomeController.to.state.currentIndex.value);

    return BottomNavigationBar(
      showUnselectedLabels: true,
      currentIndex: mIndex,
      items: [
        BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/tab/tab_music.svg",
                height: 18.h,
                width: 20.h,
                color: mIndex == 0
                    ? const Color(0xFFF940A7)
                    : const Color(0xFFD1E0F3)),
            label: '歌曲'),
        BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/tab/tab_album.svg",
                height: 18.h,
                width: 20.h,
                color: mIndex == 1
                    ? const Color(0xFFF940A7)
                    : const Color(0xFFD1E0F3)),
            label: '专辑'),
        BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/tab/tab_singer.svg",
                height: 18.h,
                width: 20.h,
                color: mIndex == 2
                    ? const Color(0xFFF940A7)
                    : const Color(0xFFD1E0F3)),
            label: '歌手'),
      ],
      elevation: 0,
      backgroundColor: colorTheme.surface,
      selectedItemColor: const Color(0xFFF940A7),
      unselectedItemColor: const Color(0xFFD1E0F3),
      onTap: (index) {
        mIndex = handlePage(index);
        setState(() {});
        HomeController.to.state.currentIndex.value = index;
        HomeController.to.resetCheckedState();///重置选中状态
        HomeController.to.update();
      },
    );
  }

  int handlePage(int index) {
    return index % 3;
  }
}
