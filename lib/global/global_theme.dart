import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

final ThemeData theme = ThemeData();

//主题
final ThemeData lightTheme = ThemeData(
    hintColor: Colors.green[300],
    brightness: Brightness.light,
    bottomAppBarColor: Colors.black,
    primaryColor: ColorMs.colorLightPrimary,
    canvasColor: ColorMs.colorLightPrimary,
    scaffoldBackgroundColor: ColorMs.colorLightPrimary,
    textTheme: TextTheme(titleSmall: TextStyleMs.black_14),
    iconTheme: IconThemeData(color: Colors.grey[800]),
    appBarTheme: AppBarTheme(
      shadowColor: Colors.green[300]?.withOpacity(.1),
      elevation: 0.0,
    ));
final ThemeData darkTheme = ThemeData(
    hintColor: Colors.blue[300],
    brightness: Brightness.dark,
    bottomAppBarColor: Colors.white,
    primaryColor: ColorMs.colorNightPrimary,
    canvasColor: ColorMs.colorNightPrimary,
    scaffoldBackgroundColor: ColorMs.colorNightPrimary,
    textTheme: TextTheme(titleSmall: TextStyleMs.white_14),
    iconTheme: IconThemeData(color: Colors.grey[300]),
    appBarTheme: AppBarTheme(
      shadowColor: Colors.blue[300]?.withOpacity(.1),
      elevation: 0.0,
    ));
