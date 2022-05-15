import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//主题
final ThemeData lightTheme = ThemeData(
    accentColor: Colors.green[300],
    brightness: Brightness.light,
    primaryColor: const Color(0xFFF2F8FF),
    scaffoldBackgroundColor: const Color(0xFFF2F8FF),
    bottomAppBarColor: Colors.black,
    textTheme: TextTheme(
        // bodyMedium: TextStyle(fontSize: 15.sp, color: const Color(0xFF333333)),
        titleSmall: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333))),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    canvasColor: const Color(0xFFF2F8FF),
    appBarTheme: AppBarTheme(
      shadowColor: Colors.green[300]?.withOpacity(.1),
      elevation: 0.0,
    ));
final ThemeData darkTheme = ThemeData(
    accentColor: Colors.blue[300],
    brightness: Brightness.dark,
    bottomAppBarColor: Colors.white,
    primaryColor: Colors.grey[850],
    canvasColor: Colors.grey[850],
    scaffoldBackgroundColor: Colors.grey[850],
    textTheme: TextTheme(
        // bodyMedium: TextStyle(fontSize: 15.sp, color: Colors.white),
        titleSmall: TextStyle(fontSize: 14.sp, color: Colors.white)),
    iconTheme: IconThemeData(color: Colors.grey[300]),
    appBarTheme: AppBarTheme(
      shadowColor: Colors.blue[300]?.withOpacity(.1),
      elevation: 0.0,
    ));
