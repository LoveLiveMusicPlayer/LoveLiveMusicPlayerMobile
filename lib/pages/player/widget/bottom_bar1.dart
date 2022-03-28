import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main/logic.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  var logic = Get.find<MainLogic>();
  var mIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    mIndex = handlePage(logic.state.currentIndex);

    return BottomNavigationBar(
      currentIndex: mIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.music_note), label: '歌曲'),
        BottomNavigationBarItem(icon: Icon(Icons.library_music), label: '专辑'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: '歌手'),
      ],
      elevation: 0,
      backgroundColor: colorTheme.surface,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD91F86),
      unselectedItemColor: const Color(0xFFD1E0F3).withOpacity(0.5),
      onTap: (index) {
        mIndex = handlePage(index);
        setState(() {});
        logic.state.currentIndex = index;
        logic.update();
      },
    );
  }

  int handlePage(int index) {
    return index % 3;
  }
}
