import 'dart:convert';

import 'package:floor/floor.dart';

Music albumFromJson(String str) => Music.fromJson(json.decode(str));

String albumToJson(Music data) => json.encode(data.toJson());

@Entity(tableName: "Music")
class Music {
  Music(
      {this.musicId,
      this.musicName,
      this.artist,
      this.artistBin,
      this.albumId,
      this.albumName,
      this.coverPath,
      this.musicPath,
      this.time,
      this.category,
      this.group,
      this.baseUrl,
      this.timestamp = 0,
      this.isLove = false,
      this.checked = false});

  @primaryKey
  String? musicId; // id
  String? musicName; // 歌名
  String? artist; // 歌手
  String? artistBin; // 歌手32进制数据
  String? albumId; // 专辑id
  String? albumName; // 专辑名
  String? coverPath; // 封面路径
  String? musicPath; // 歌曲路径
  String? time; // 时长
  String? baseUrl; // 基础路径
  String? category; // 分类
  String? group; // 团组
  bool isLove; // 是否我喜欢
  int timestamp; // 最后一次播放的时间戳

  @ignore
  bool checked; // 是否已选中

  factory Music.fromJson(Map<String, dynamic> json) => Music(
        musicId: json["musicId"],
        musicName: json["musicName"],
        artist: json["artist"],
        artistBin: json["artistBin"],
        albumId: json["albumId"],
        albumName: json["albumName"],
        coverPath: json["coverPath"],
        musicPath: json["musicPath"],
        time: json["time"],
        baseUrl: json["baseUrl"],
        category: json["category"],
        group: json["group"],
        isLove: json["isLove"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "musicId": musicId,
        "musicName": musicName,
        "artist": artist,
        "artistBin": artistBin,
        "albumId": albumId,
        "albumName": albumName,
        "coverPath": coverPath,
        "musicPath": musicPath,
        "time": time,
        "baseUrl": baseUrl,
        "category": category,
        "group": group,
        "isLove": isLove,
        "timestamp": timestamp,
      };

  factory Music.deepClone(Music music) => Music(
      musicId: music.musicId,
      musicName: music.musicName,
      artist: music.artist,
      artistBin: music.artistBin,
      albumId: music.albumId,
      albumName: music.albumName,
      coverPath: music.coverPath,
      musicPath: music.musicPath,
      time: music.time,
      baseUrl: music.baseUrl,
      category: music.category,
      group: music.group,
      isLove: music.isLove,
      checked: music.checked,
      timestamp: music.timestamp
  );
}
