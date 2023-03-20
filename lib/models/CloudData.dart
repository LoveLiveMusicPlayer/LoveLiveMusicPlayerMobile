import 'dart:convert';

import 'package:lovelivemusicplayer/global/const.dart';

CloudData cloudDataFromJson(String str) => CloudData.fromJson(json.decode(str));

String cloudDataToJson(CloudData data) => json.encode(data.toJson());

class CloudData {
  CloudData({
    required this.version,
    required this.album,
    required this.music,
  });

  int version;
  Album album;
  Music music;

  factory CloudData.fromJson(Map<String, dynamic> json) => CloudData(
        version: json["version"],
        album: Album.fromJson(json["album"]),
        music: Music.fromJson(json["music"]),
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "album": album.toJson(),
        "music": music.toJson(),
      };
}

class Album {
  Album({
    required this.us,
    required this.aqours,
    required this.nijigasaki,
    required this.liella,
    required this.combine,
    required this.hasunosora,
  });

  List<InnerAlbum> us;
  List<InnerAlbum> aqours;
  List<InnerAlbum> nijigasaki;
  List<InnerAlbum> liella;
  List<InnerAlbum> combine;
  List<InnerAlbum> hasunosora;

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        us: List<InnerAlbum>.from(
            json[Const.groupUs].map((x) => InnerAlbum.fromJson(x))),
        aqours: List<InnerAlbum>.from(
            json[Const.groupAqours].map((x) => InnerAlbum.fromJson(x))),
        nijigasaki: List<InnerAlbum>.from(
            json[Const.groupSaki].map((x) => InnerAlbum.fromJson(x))),
        liella: List<InnerAlbum>.from(
            json[Const.groupLiella].map((x) => InnerAlbum.fromJson(x))),
        combine: List<InnerAlbum>.from(
            json[Const.groupCombine].map((x) => InnerAlbum.fromJson(x))),
        hasunosora: List<InnerAlbum>.from(
            json[Const.groupHasunosora].map((x) => InnerAlbum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        Const.groupUs: List<dynamic>.from(us.map((x) => x.toJson())),
        Const.groupAqours: List<dynamic>.from(aqours.map((x) => x.toJson())),
        Const.groupSaki: List<dynamic>.from(nijigasaki.map((x) => x.toJson())),
        Const.groupLiella: List<dynamic>.from(liella.map((x) => x.toJson())),
        Const.groupCombine: List<dynamic>.from(combine.map((x) => x.toJson())),
        Const.groupHasunosora: List<dynamic>.from(hasunosora.map((x) => x.toJson())),
      };
}

class InnerAlbum {
  InnerAlbum({
    required this.albumUId,
    required this.id,
    required this.name,
    required this.date,
    required this.coverPath,
    required this.category,
    required this.music,
  });

  String albumUId;
  int id;
  String name;
  String date;
  List<String> coverPath;
  String category;
  List<int> music;

  factory InnerAlbum.fromJson(Map<String, dynamic> json) => InnerAlbum(
        albumUId: json["_id"],
        id: json["id"],
        name: json["name"],
        date: json["date"],
        coverPath: List<String>.from(json["cover_path"].map((x) => x)),
        category: json["category"],
        music: List<int>.from(json["music"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": albumUId,
        "id": id,
        "name": name,
        "date": date,
        "cover_path": List<String>.from(coverPath.map((x) => x)),
        "category": category,
        "music": List<dynamic>.from(music.map((x) => x)),
      };
}

class Music {
  Music({
    required this.us,
    required this.aqours,
    required this.nijigasaki,
    required this.liella,
    required this.combine,
    required this.hasunosora,
  });

  List<InnerMusic> us;
  List<InnerMusic> aqours;
  List<InnerMusic> nijigasaki;
  List<InnerMusic> liella;
  List<InnerMusic> combine;
  List<InnerMusic> hasunosora;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
        us: List<InnerMusic>.from(
            json[Const.groupUs].map((x) => InnerMusic.fromJson(x))),
        aqours: List<InnerMusic>.from(
            json[Const.groupAqours].map((x) => InnerMusic.fromJson(x))),
        nijigasaki: List<InnerMusic>.from(
            json[Const.groupSaki].map((x) => InnerMusic.fromJson(x))),
        liella: List<InnerMusic>.from(
            json[Const.groupLiella].map((x) => InnerMusic.fromJson(x))),
        combine: List<InnerMusic>.from(
            json[Const.groupCombine].map((x) => InnerMusic.fromJson(x))),
        hasunosora: List<InnerMusic>.from(
            json[Const.groupHasunosora].map((x) => InnerMusic.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        Const.groupUs: List<dynamic>.from(us.map((x) => x.toJson())),
        Const.groupAqours: List<dynamic>.from(aqours.map((x) => x.toJson())),
        Const.groupSaki: List<dynamic>.from(nijigasaki.map((x) => x.toJson())),
        Const.groupLiella: List<dynamic>.from(liella.map((x) => x.toJson())),
        Const.groupCombine: List<dynamic>.from(combine.map((x) => x.toJson())),
        Const.groupHasunosora: List<dynamic>.from(hasunosora.map((x) => x.toJson())),
      };
}

class InnerMusic {
  InnerMusic({
    required this.musicUId,
    required this.id,
    required this.name,
    required this.albumId,
    required this.coverPath,
    required this.musicPath,
    required this.artist,
    required this.artistBin,
    required this.time,
    required this.export,
    required this.baseUrl,
    required this.neteaseId,
    required this.albumName,
  });

  String musicUId;
  int id;
  String name;
  int albumId;
  String coverPath;
  String musicPath;
  String artist;
  String artistBin;
  String time;
  String? albumName;
  bool export;
  String baseUrl;
  String? neteaseId;

  factory InnerMusic.fromJson(Map<String, dynamic> json) {
    return InnerMusic(
      musicUId: json["_id"],
      id: json["id"],
      name: json["name"],
      albumId: json["album"],
      coverPath: json["cover_path"],
      musicPath: json["music_path"],
      artist: json["artist"],
      artistBin: json["artist_bin"],
      time: json["time"],
      albumName: json["albumName"],
      export: json["export"],
      baseUrl: json["base_url"],
      neteaseId: json["neteaseId"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": musicUId,
        "id": id,
        "name": name,
        "album": albumId,
        "cover_path": coverPath,
        "music_path": musicPath,
        "artist": artist,
        "artist_bin": artistBin,
        "time": time,
        "albumName": albumName,
        "export": export,
        "base_url": baseUrl,
        "neteaseId": neteaseId,
      };
}
