import 'dart:convert';

Music musicFromJson(String str) => Music.fromJson(json.decode(str));

String musicToJson(Music data) => json.encode(data.toJson());

class Music {
  Music({
    this.name,
    this.cover,
    this.singer,
    this.time,
    this.jpLrc,
    this.zhLrc,
    this.romaLrc,
    this.preJPLrc = "はすんだ！",
    this.currentJPLrc = "だから僕らは鳴らすんだ！",
    this.nextJPLrc = "だか鳴ららはすんだ！",
  });

  String? name;
  String? cover;
  String? singer;
  String? time;

  String? jpLrc;
  String? zhLrc;
  String? romaLrc;

  String? preJPLrc;
  String? currentJPLrc;
  String? nextJPLrc;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    name: json["name"],
    cover: json["cover"],
    singer: json["singer"],
    time: json["time"],

    jpLrc: json["jpLrc"],
    zhLrc: json["zhLrc"],
    romaLrc: json["romaLrc"],

    preJPLrc: json["preJPLrc"],
    currentJPLrc: json["currentJPLrc"],
    nextJPLrc: json["nextJPLrc"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "cover": cover,
    "singer": singer,
    "time": time,

    "jpLrc": jpLrc,
    "zhLrc": zhLrc,
    "romaLrc": romaLrc,

    "preJPLrc": preJPLrc,
    "currentJPLrc": currentJPLrc,
    "nextJPLrc": nextJPLrc,
  };
}
