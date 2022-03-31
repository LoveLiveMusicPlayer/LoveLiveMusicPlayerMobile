import 'dart:convert';
import 'package:floor/floor.dart';

Album albumFromJson(String str) => Album.fromJson(json.decode(str));

String albumToJson(Album data) => json.encode(data.toJson());

@Entity(tableName: "Album")
class Album {
  @primaryKey
  String? uid; //唯一标识
  String? name; //专辑名称
  String? date; //时间

  List<String>? coverPath; //封面

  String? category; //类别

  List<String>? music;

  bool isPlaying;

  Album({
    this.uid,
    this.name,
    this.date,
    this.coverPath,
    this.category,
    this.music,
    this.isPlaying = false
  }); //对应歌曲id

  factory Album.fromJson(Map<String, dynamic> json) =>
      Album(
        uid: json["uid"],
        name: json["name"],
        date: json["date"],
        coverPath: List<String>.from(json["coverPath"].map((x) => x)),
        category: json["category"],
        music: List<String>.from(json["music"].map((x) => x)),
        isPlaying: json["isPlaying"],
      );

  Map<String, dynamic> toJson() =>
      {
        "uid": uid,
        "name": name,
        "date": date,
        "coverPath": List<dynamic>.from(coverPath!.map((x) => x)),
        "category": category,
        "music": List<dynamic>.from(music!.map((x) => x)),

        "isPlaying": isPlaying,
      };
}
