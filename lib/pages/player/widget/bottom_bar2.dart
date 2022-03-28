import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main/logic.dart';

class BottomBar2 extends StatefulWidget {
  const BottomBar2({Key? key}) : super(key: key);

  @override
  State<BottomBar2> createState() => _BottomBar2State();
}

class _BottomBar2State extends State<BottomBar2> {
  var logic = Get.find<MainLogic>();
  var mIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    mIndex = handlePage(logic.state.currentIndex);
    return BottomNavigationBar(
      currentIndex: mIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '我喜欢'),
        BottomNavigationBarItem(icon: Icon(Icons.library_music), label: '歌单'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: '最近播放'),
      ],
      elevation: 0,
      backgroundColor: colorTheme.surface,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD91F86),
      unselectedItemColor: const Color(0xFFD1E0F3).withOpacity(0.5),
      onTap: (index) {
        mIndex = handlePage(index + 3);
        setState(() {});
        logic.state.currentIndex = index + 3;
        logic.update();
      },
    );
  }

  int handlePage(int index) {
    return index % 3;
  }
}
