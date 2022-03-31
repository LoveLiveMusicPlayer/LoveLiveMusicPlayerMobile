import 'dart:convert';
import 'package:floor/floor.dart';

Music musicFromJson(String str) => Music.fromJson(json.decode(str));

String musicToJson(Music data) => json.encode(data.toJson());

@Entity(tableName: "Music")
class Music {
  Music({
    this.uid,
    this.name,
    this.albumId,
    this.albumName,
    this.coverPath,
    this.musicPath,
    this.artist,
    this.artistBin,
    this.totalTime,
    this.jpUrl,
    this.zhUrl,
    this.romaUrl,
    this.isLove = false,
    this.isPlaying = false
  });


  /// 实体层属性
  @primaryKey
  String? uid; // id
  String? name; // 歌名
  String? albumId; // 专辑id
  String? albumName; // 专辑名
  String? coverPath; // 封面路径
  String? musicPath; // 歌曲路径
  String? artist; // 歌手
  String? artistBin; // 歌手32进制数据
  String? totalTime; // 时长
  String? jpUrl; // 日文歌词 URL
  String? zhUrl; // 中文歌词 URL
  String? romaUrl; // 罗马音歌词 URL
  bool isLove; // 是否我喜欢

  bool isPlaying; // 是否当前播放

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    uid: json["uid"],
    name: json["name"],
    coverPath: json["coverPath"],
    musicPath: json["musicPath"],
    artist: json["artist"],
    artistBin: json["artistBin"],
    totalTime: json["totalTime"],
    jpUrl: json["jpUrl"],
    zhUrl: json["zhUrl"],
    romaUrl: json["romaUrl"],
    isLove: json["isLove"],

    isPlaying: json["isPlaying"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "coverPath": coverPath,
    "musicPath": musicPath,
    "artist": artist,
    "artistBin": artistBin,
    "totalTime": totalTime,
    "jpUrl": jpUrl,
    "zhUrl": zhUrl,
    "romaUrl": romaUrl,
    "isLove": isLove,

    "isPlaying": isPlaying,
  };
}
