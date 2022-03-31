// To parse this JSON data, do
//
//     final ftpMusic = ftpMusicFromJson(jsonString);

import 'dart:convert';

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

class Music {
  Music({
    required this.id,
    required this.name,
    required this.album,
    required this.coverPath,
    required this.musicPath,
    required this.artist,
    required this.artistBin,
    required this.time,
    required this.lyric,
    required this.trans,
    required this.roma,
    required this.albumName,
  });

  String id;
  String name;
  String album;
  String coverPath;
  String musicPath;
  String artist;
  String artistBin;
  String time;
  String lyric;
  String trans;
  String roma;
  String albumName;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    id: json["_id"],
    name: json["name"],
    album: json["album"],
    coverPath: json["cover_path"],
    musicPath: json["music_path"],
    artist: json["artist"],
    artistBin: json["artist_bin"],
    time: json["time"],
    lyric: json["lyric"],
    trans: json["trans"],
    roma: json["roma"],
    albumName: json["albumName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "album": album,
    "cover_path": coverPath,
    "music_path": musicPath,
    "artist": artist,
    "artist_bin": artistBin,
    "time": time,
    "lyric": lyric,
    "trans": trans,
    "roma": roma,
    "albumName": albumName,
  };
}
