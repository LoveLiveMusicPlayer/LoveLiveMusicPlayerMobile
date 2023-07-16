import 'dart:convert';

import 'package:floor/floor.dart';

Artist artistDaoFromJson(String str) => Artist.fromJson(json.decode(str));

String artistDaoToJson(Artist data) => json.encode(data.toJson());

@Entity(tableName: "Artist", primaryKeys: ['id'])
class Artist {
  Artist(
      {this.id,
      required this.uid,
      required this.name,
      required this.photo,
      required this.music,
      required this.group});

  @PrimaryKey(autoGenerate: true)
  int? id;
  String uid;
  String name;
  String photo;
  String group;
  List<String> music;

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
        id: json["id"],
        uid: json["uid"],
        name: json["name"],
        photo: json["photo"],
        group: json["group"],
        music: List<String>.from(json["music"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "name": name,
        "photo": photo,
        "group": group,
        "music": List<String>.from(music.map((x) => x)),
      };
}
