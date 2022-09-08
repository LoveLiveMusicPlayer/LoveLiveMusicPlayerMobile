import 'dart:convert';

TransData transDataFromJson(String str) => TransData.fromJson(json.decode(str));

String transDataToJson(TransData data) => json.encode(data.toJson());

class TransData {
  TransData({
    required this.love,
    required this.menu,
  });

  List<String> love;
  List<TransMenu> menu;

  factory TransData.fromJson(Map<String, dynamic> json) => TransData(
    love: List<String>.from(json["love"].map((x) => x)),
    menu: List<TransMenu>.from(json["menu"].map((x) => TransMenu.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "love": List<dynamic>.from(love.map((x) => x)),
    "menu": List<dynamic>.from(menu.map((x) => x.toJson())),
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
