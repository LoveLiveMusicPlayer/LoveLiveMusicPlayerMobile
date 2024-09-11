import 'dart:convert';

import 'package:floor/floor.dart';

Menu menuFromJson(String str) => Menu.fromJson(json.decode(str));

String menuToJson(Menu data) => json.encode(data.toJson());

@Entity(tableName: "Menu")
class Menu {
  Menu(
      {required this.id,
      this.isPhone = true,
      this.music = const <String>[],
      required this.date,
      required this.name,
      this.checked = false,
      this.coverPath});

  @primaryKey
  int id;
  bool isPhone;
  List<String> music;
  String date;
  String name;

  @ignore
  bool checked;
  @ignore
  String? coverPath;

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        id: json["id"],
        isPhone: json["isPhone"],
        music: List<String>.from(json["music"].map((x) => x)),
        date: json["date"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isPhone": isPhone,
        "music": music,
        "date": date,
        "name": name,
      };
}
