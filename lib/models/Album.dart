import 'dart:convert';

import 'package:floor/floor.dart';

import 'Music.dart';

Album albumFromJson(String str) => Album.fromJson(json.decode(str));

String albumToJson(Album data) => json.encode(data.toJson());

@Entity(tableName: "Album")
class Album {
  @primaryKey
  String? uid; //唯一标识
  String? name; //专辑名称
  String? date; //时间
  String? group; // 团组

  List<String>? coverPath; //封面

  String? category; //类别

  List<Music> music;

  @ignore
  bool isPlaying;

  Album(
      {this.uid,
      this.name,
      this.date,
      this.coverPath,
      this.category,
      this.group,
      this.music = const <Music>[],
      this.isPlaying = false}); //对应歌曲id

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        uid: json["_id"],
        name: json["name"],
        date: json["date"],
        group: json["group"],
        coverPath: List<String>.from(json["cover_path"].map((x) => x)),
        category: json["category"],
        music: List<Music>.from(json["music"].map((x) => x)),
        isPlaying: json["isPlaying"] == 1 ? true : false,
      );

  Map<String, dynamic> toJson() => {
        "_id": uid,
        "name": name,
        "date": date,
        "group": group,
        "cover_path": List<String>.from(coverPath!.map((x) => x)),
        "category": category,
        "music": music,
        "isPlaying": isPlaying ? 1 : 0,
      };
}
