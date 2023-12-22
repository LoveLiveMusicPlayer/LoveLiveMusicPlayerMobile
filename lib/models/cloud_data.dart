import 'dart:convert';

import 'package:lovelivemusicplayer/models/group.dart';

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
    required this.yohane,
  });

  List<InnerAlbum> us;
  List<InnerAlbum> aqours;
  List<InnerAlbum> nijigasaki;
  List<InnerAlbum> liella;
  List<InnerAlbum> combine;
  List<InnerAlbum> hasunosora;
  List<InnerAlbum> yohane;

  factory Album.fromJson(Map<String, dynamic> json) {
    List<InnerAlbum> json2Obj(Map<String, dynamic> json, String key) {
      return json.containsKey(key)
          ? List<InnerAlbum>.from(json[key].map((x) => InnerAlbum.fromJson(x)))
          : [];
    }

    return Album(
      us: json2Obj(json, GroupKey.groupUs.getName()),
      aqours: json2Obj(json, GroupKey.groupAqours.getName()),
      nijigasaki: json2Obj(json, GroupKey.groupNijigasaki.getName()),
      liella: json2Obj(json, GroupKey.groupLiella.getName()),
      combine: json2Obj(json, GroupKey.groupCombine.getName()),
      hasunosora: json2Obj(json, GroupKey.groupHasunosora.getName()),
      yohane: json2Obj(json, GroupKey.groupYohane.getName()),
    );
  }

  List<dynamic> obj2Json(List<InnerAlbum> obj) {
    return List<dynamic>.from(obj.map((x) => x.toJson()));
  }

  Map<String, dynamic> toJson() => {
        GroupKey.groupUs.getName(): obj2Json(us),
        GroupKey.groupAqours.getName(): obj2Json(aqours),
        GroupKey.groupNijigasaki.getName(): obj2Json(nijigasaki),
        GroupKey.groupLiella.getName(): obj2Json(liella),
        GroupKey.groupCombine.getName(): obj2Json(combine),
        GroupKey.groupHasunosora.getName(): obj2Json(hasunosora),
        GroupKey.groupYohane.getName(): obj2Json(yohane),
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
    required this.yohane,
  });

  List<InnerMusic> us;
  List<InnerMusic> aqours;
  List<InnerMusic> nijigasaki;
  List<InnerMusic> liella;
  List<InnerMusic> combine;
  List<InnerMusic> hasunosora;
  List<InnerMusic> yohane;

  factory Music.fromJson(Map<String, dynamic> json) {
    List<InnerMusic> json2Obj(Map<String, dynamic> json, String key) {
      return json.containsKey(key)
          ? List<InnerMusic>.from(json[key].map((x) => InnerMusic.fromJson(x)))
          : [];
    }

    return Music(
      us: json2Obj(json, GroupKey.groupUs.getName()),
      aqours: json2Obj(json, GroupKey.groupAqours.getName()),
      nijigasaki: json2Obj(json, GroupKey.groupNijigasaki.getName()),
      liella: json2Obj(json, GroupKey.groupLiella.getName()),
      combine: json2Obj(json, GroupKey.groupCombine.getName()),
      hasunosora: json2Obj(json, GroupKey.groupHasunosora.getName()),
      yohane: json2Obj(json, GroupKey.groupYohane.getName()),
    );
  }

  List<dynamic> obj2Json(List<InnerMusic> obj) {
    return List<dynamic>.from(obj.map((x) => x.toJson()));
  }

  Map<String, dynamic> toJson() => {
        GroupKey.groupUs.getName(): obj2Json(us),
        GroupKey.groupAqours.getName(): obj2Json(aqours),
        GroupKey.groupNijigasaki.getName(): obj2Json(nijigasaki),
        GroupKey.groupLiella.getName(): obj2Json(liella),
        GroupKey.groupCombine.getName(): obj2Json(combine),
        GroupKey.groupHasunosora.getName(): obj2Json(hasunosora),
        GroupKey.groupYohane.getName(): obj2Json(yohane),
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

  factory InnerMusic.fromJson(Map<String, dynamic> json) => InnerMusic(
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
