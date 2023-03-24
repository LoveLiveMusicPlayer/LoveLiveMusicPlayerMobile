// To parse this JSON data, do
//
//     final shareMenu = shareMenuFromJson(jsonString);

import 'dart:convert';

ShareMenu shareMenuFromJson(String str) => ShareMenu.fromJson(json.decode(str));

String shareMenuToJson(ShareMenu data) => json.encode(data.toJson());

class ShareMenu {
  ShareMenu({
    required this.menuName,
    required this.musicList,
  });

  String menuName;
  List<SharedMusic> musicList;

  factory ShareMenu.fromJson(Map<String, dynamic> json) => ShareMenu(
        menuName: json["menuName"],
        musicList: List<SharedMusic>.from(
            json["musicList"].map((x) => SharedMusic.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "menuName": menuName,
        "musicList": List<dynamic>.from(musicList.map((x) => x.toJson())),
      };
}

SharedMusic shareMusicFromJson(String str) =>
    SharedMusic.fromJson(json.decode(str));

String shareMusicToJson(SharedMusic data) => json.encode(data.toJson());

class SharedMusic {
  SharedMusic({
    required this.id,
    required this.name,
    required this.neteaseId,
  });

  String id;
  String name;
  String? neteaseId;

  factory SharedMusic.fromJson(Map<String, dynamic> json) => SharedMusic(
        id: json["_id"],
        name: json["name"],
        neteaseId: json["neteaseId"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "neteaseId": neteaseId,
      };
}
