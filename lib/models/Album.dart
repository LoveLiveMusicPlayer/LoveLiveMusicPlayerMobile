import 'dart:convert';
import 'package:floor/floor.dart';

Album albumFromJson(String str) => Album.fromJson(json.decode(str));

String albumToJson(Album data) => json.encode(data.toJson());

@Entity(tableName: "Album")
class Album {
  Album({
    this.albumId,   // 唯一标识
    this.albumName, // 专辑名称
    this.date,      // 时间
    this.coverPath, // 封面
    this.category,  // 分类
    this.group,  // 团组
  });

  @primaryKey
  String? albumId;
  String? albumName;
  String? date;
  String? coverPath;
  String? category;
  String? group;

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    albumId: json["albumId"],
    albumName: json["albumName"],
    date: json["date"],
    coverPath: json["coverPath"],
    category: json["category"],
    group: json["group"],
  );

  Map<String, dynamic> toJson() => {
    "albumId": albumId,
    "albumName": albumName,
    "date": date,
    "coverPath": coverPath,
    "category": category,
    "group": group,
  };
}
