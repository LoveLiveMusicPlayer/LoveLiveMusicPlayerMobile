import 'package:flutter/material.dart';

class BottomBar2 extends StatelessWidget {
  final int currentIndex;
  final Function onSelect;

  const BottomBar2(this.currentIndex, {Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    return BottomNavigationBar(
      currentIndex: currentIndex,
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
        onSelect(index);
      },
    );
  }
}
