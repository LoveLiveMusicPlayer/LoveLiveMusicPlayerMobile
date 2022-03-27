import 'dart:convert';

Music musicFromJson(String str) => Music.fromJson(json.decode(str));

String musicToJson(Music data) => json.encode(data.toJson());

class Music {
  Music({
    this.uid,
    this.id,
    this.name,
    this.cover,
    this.singer,
    this.playedTime,
    this.totalTime,
    this.jpLrc,
    this.zhLrc,
    this.romaLrc,
    this.preJPLrc = "はすんだ！",
    this.currentJPLrc = "だから僕らは鳴らすんだ！",
    this.nextJPLrc = "だか鳴ららはすんだ！",
    this.isPlaying = false
  });

  String? uid;
  int? id;

  String? name;
  String? cover;
  String? singer;
  String? playedTime;
  String? totalTime;

  String? jpLrc;
  String? zhLrc;
  String? romaLrc;

  String? preJPLrc;
  String? currentJPLrc;
  String? nextJPLrc;

  bool isPlaying;


  factory Music.fromJson(Map<String, dynamic> json) => Music(
    uid: json["uid"],
    id: json["id"],
    name: json["name"],
    cover: json["cover"],
    singer: json["singer"],
    playedTime: json["playedTime"],
    totalTime: json["totalTime"],

    jpLrc: json["jpLrc"],
    zhLrc: json["zhLrc"],
    romaLrc: json["romaLrc"],

    preJPLrc: json["preJPLrc"],
    currentJPLrc: json["currentJPLrc"],
    nextJPLrc: json["nextJPLrc"],

    isPlaying: json["isPlaying"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "id": id,
    "name": name,
    "cover": cover,
    "singer": singer,
    "playedTime": playedTime,
    "totalTime": totalTime,

    "jpLrc": jpLrc,
    "zhLrc": zhLrc,
    "romaLrc": romaLrc,

    "preJPLrc": preJPLrc,
    "currentJPLrc": currentJPLrc,
    "nextJPLrc": nextJPLrc,

    "isPlaying": isPlaying,
  };
}
