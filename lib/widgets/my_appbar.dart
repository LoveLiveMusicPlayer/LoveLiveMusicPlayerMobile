import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;

  const MyAppbar({super.key, this.title, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: preferredSize.height,
      child: Center(
        child: Text(title ?? ""),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40.0);
}
