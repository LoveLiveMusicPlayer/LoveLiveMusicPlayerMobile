// To parse this JSON data, do
//
//     final downloadMusic = downloadMusicFromJson(jsonString);

import 'dart:convert';

List<DownloadMusic> downloadMusicFromJson(String str) => List<DownloadMusic>.from(json.decode(str).map((x) => DownloadMusic.fromJson(x)));

String downloadMusicToJson(List<DownloadMusic> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DownloadMusic {
  DownloadMusic({
    required this.albumUId,
    required this.albumId,
    required this.albumName,
    required this.coverPath,
    required this.date,
    required this.category,
    required this.group,
    required this.musicUId,
    required this.musicId,
    required this.musicName,
    required this.musicPath,
    required this.artist,
    required this.artistBin,
    required this.totalTime,
    required this.jpUrl,
    required this.zhUrl,
    required this.romaUrl
  });

  String albumUId;
  int albumId;
  String albumName;
  String coverPath;
  String date;
  String category;
  String group;
  String musicUId;
  int musicId;
  String musicName;
  String musicPath;
  String artist;
  String artistBin;
  String totalTime;
  String jpUrl;
  String zhUrl;
  String romaUrl;

  factory DownloadMusic.fromJson(Map<String, dynamic> json) => DownloadMusic(
    albumUId: json["albumUId"],
    albumId: json["albumId"],
    albumName: json["albumName"],
    coverPath: json["coverPath"],
    date: json["date"],
    category: json["category"],
    group: json["group"],
    musicUId: json["musicUId"],
    musicId: json["musicId"],
    musicName: json["musicName"],
    musicPath: json["musicPath"],
    artist: json["artist"],
    artistBin: json["artistBin"],
    totalTime: json["totalTime"],
    jpUrl: json["jpUrl"],
    zhUrl: json["zhUrl"],
    romaUrl: json["romaUrl"]
  );

  Map<String, dynamic> toJson() => {
    "albumUId": albumUId,
    "albumId": albumId,
    "albumName": albumName,
    "coverPath": coverPath,
    "date": date,
    "category": category,
    "group": group,
    "musicUId": musicUId,
    "musicId": musicId,
    "musicName": musicName,
    "musicPath": musicPath,
    "artist": artist,
    "artistBin": artistBin,
    "totalTime": totalTime,
    "jpUrl": jpUrl,
    "zhUrl": zhUrl,
    "romaUrl": romaUrl
  };
}
