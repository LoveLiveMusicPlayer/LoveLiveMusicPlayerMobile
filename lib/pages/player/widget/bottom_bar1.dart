import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function onSelect;

  const BottomBar(this.currentIndex, {Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    return BottomNavigationBar(
      currentIndex: currentIndex,
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
        onSelect(index);
      },
    );
  }
}
