import 'dart:convert';

import 'package:lovelivemusicplayer/models/love.dart';

TransData transDataFromJson(String str) => TransData.fromJson(json.decode(str));

String transDataToJson(TransData data) => json.encode(data.toJson());

class TransData {
  TransData({required this.love, required this.menu, required this.isCover});

  List<Love> love;
  List<TransMenu> menu;
  bool isCover;

  factory TransData.fromJson(Map<String, dynamic> json) => TransData(
      love: List<Love>.from(json["love"].map((x) => Love.fromJson(x))),
      menu:
          List<TransMenu>.from(json["menu"].map((x) => TransMenu.fromJson(x))),
      isCover: json["isCover"]);

  Map<String, dynamic> toJson() => {
        "love": List<dynamic>.from(love.map((x) => x.toJson())),
        "menu": List<dynamic>.from(menu.map((x) => x.toJson())),
        "isCover": isCover
      };
}

class TransMenu {
  TransMenu({
    required this.menuId,
    required this.name,
    required this.musicList,
    required this.date,
  });

  int menuId;
  String name;
  String date;
  List<String> musicList;

  factory TransMenu.fromJson(Map<String, dynamic> json) => TransMenu(
        menuId: json["menuId"],
        name: json["name"],
        date: json["date"],
        musicList: List<String>.from(json["musicList"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "menuId": menuId,
        "name": name,
        "date": date,
        "musicList": List<dynamic>.from(musicList.map((x) => x)),
      };
}
