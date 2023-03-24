import 'dart:convert';

import 'package:floor/floor.dart';

Lyric lyricFromJson(String str) => Lyric.fromJson(json.decode(str));

String lyricToJson(Lyric data) => json.encode(data.toJson());

@Entity(tableName: "Lyric")
class Lyric {
  Lyric({
    this.uid,
    this.jp,
    this.zh,
    this.roma,
  });

  @primaryKey
  String? uid;
  String? jp;
  String? zh;
  String? roma;

  factory Lyric.fromJson(Map<String, dynamic> json) => Lyric(
        uid: json["uid"],
        jp: json["jp"],
        zh: json["zh"],
        roma: json["roma"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "jp": jp,
        "zh": zh,
        "roma": roma,
      };
}
