import 'dart:convert';
import 'Music.dart';

List<FtpMusic> ftpMusicFromJson(String str) => List<FtpMusic>.from(json.decode(str).map((x) => FtpMusic.fromJson(x)));

String ftpMusicToJson(List<FtpMusic> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FtpMusic {
  FtpMusic({
    required this.id,
    required this.name,
    required this.date,
    required this.coverPath,
    required this.category,
    required this.music,
    required this.group,
  });

  String id;
  String name;
  String date;
  List<String> coverPath;
  String category;
  List<Music> music;
  String group;

  factory FtpMusic.fromJson(Map<String, dynamic> json) => FtpMusic(
    id: json["_id"],
    name: json["name"],
    date: json["date"],
    coverPath: List<String>.from(json["cover_path"].map((x) => x)),
    category: json["category"],
    music: List<Music>.from(json["music"].map((x) => Music.fromJson(x))),
    group: json["group"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "date": date,
    "cover_path": List<dynamic>.from(coverPath.map((x) => x)),
    "category": category,
    "music": List<dynamic>.from(music.map((x) => x.toJson())),
    "group": group,
  };
}