import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';

class BottomBar2 extends StatefulWidget {
  const BottomBar2({Key? key}) : super(key: key);

  @override
  State<BottomBar2> createState() => _BottomBar2State();
}

class _BottomBar2State extends State<BottomBar2> {
  var mIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Get.theme.colorScheme;
    mIndex = handlePage(HomeController.to.state.currentIndex.value);
    return BottomNavigationBar(
      showUnselectedLabels: true,
      currentIndex: mIndex,
      items: [
        BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.tabTabLove,
                height: 18.h,
                width: 20.h,
                color: mIndex == 0
                    ? const Color(0xFFF940A7)
                    : const Color(0xFFD1E0F3)),
            label: '我喜欢'),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.tabTabPlaylist,
                height: 18.h,
                width: 20.h,
                color: mIndex == 1
                    ? const Color(0xFFF940A7)
                    : const Color(0xFFD1E0F3)),
            label: '歌单'),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.tabTabRecently,
                height: 18.h,
                width: 20.h,
                color: mIndex == 2
                    ? const Color(0xFFF940A7)
                    : const Color(0xFFD1E0F3)),
            label: '最近播放'),
      ],
      elevation: 0,
      backgroundColor: colorTheme.surface,
      selectedFontSize: 13.sp,
      unselectedFontSize: 13.sp,
      selectedItemColor: const Color(0xFFD91F86),
      unselectedItemColor: const Color(0xFFA9B9CD).withOpacity(0.5),
      onTap: (index) {
        mIndex = handlePage(index + 3);
        setState(() {});
        HomeController.to.state.currentIndex.value = index + 3;
        HomeController.to.update();
      },
    );
  }

  int handlePage(int index) {
    return index % 3;
  }
}
