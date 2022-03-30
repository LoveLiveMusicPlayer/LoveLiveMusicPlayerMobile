// To parse this JSON data, do
//
//     final songData = songDataFromJson(jsonString);

import 'dart:convert';

SongData songDataFromJson(String str) => SongData.fromJson(json.decode(str));

String songDataToJson(SongData data) => json.encode(data.toJson());

class SongData {
  SongData({
    this.version = 0,
    this.album,
    this.music,
  });

  int version;
  Album? album;
  Music? music;

  factory SongData.fromJson(Map<String, dynamic> json) => SongData(
    version: json["version"],
    album: Album.fromJson(json["album"]),
    music: Music.fromJson(json["music"]),
  );

  Map<String, dynamic> toJson() => {
    "version": version,
    "album": album?.toJson(),
    "music": music?.toJson(),
  };
}

class Album {
  Album({
    required this.s,
    required this.aqours,
    required this.nijigasaki,
    required this.liella,
    required this.combine,
  });

  List<AlbumAqour> s;
  List<AlbumAqour> aqours;
  List<AlbumAqour> nijigasaki;
  List<AlbumAqour> liella;
  List<AlbumAqour> combine;

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    s: List<AlbumAqour>.from(json["μ's"].map((x) => AlbumAqour.fromJson("μ's",x))),
    aqours: List<AlbumAqour>.from(json["Aqours"].map((x) => AlbumAqour.fromJson("Aqours",x))),
    nijigasaki: List<AlbumAqour>.from(json["Nijigasaki"].map((x) => AlbumAqour.fromJson("Nijigasaki",x))),
    liella: List<AlbumAqour>.from(json["Liella!"].map((x) => AlbumAqour.fromJson("Liella!",x))),
    combine: List<AlbumAqour>.from(json["Combine"].map((x) => AlbumAqour.fromJson("Combine",x))),
  );

  Map<String, dynamic> toJson() => {
    "μ's": List<dynamic>.from(s.map((x) => x.toJson())),
    "Aqours": List<dynamic>.from(aqours.map((x) => x.toJson())),
    "Nijigasaki": List<dynamic>.from(nijigasaki.map((x) => x.toJson())),
    "Liella!": List<dynamic>.from(liella.map((x) => x.toJson())),
    "Combine": List<dynamic>.from(combine.map((x) => x.toJson())),
  };
}

class AlbumAqour {
  AlbumAqour({
    required this.type,
    required this.id,
    required this.aqourId,
    required this.name,
    required this.date,
    required this.coverPath,
    required this.category,
    required this.music,
  });


  String type;
  String id;
  int aqourId;
  String name;
  String date;
  List<String> coverPath;
  String category;
  List<int> music;

  factory AlbumAqour.fromJson(String key,Map<String, dynamic> json) => AlbumAqour(
    type: key,
    id: json["_id"],
    aqourId: json["id"],
    name: json["name"],
    date: json["date"],
    coverPath: List<String>.from(json["cover_path"].map((x) => x)),
    category: json["category"],
    music: List<int>.from(json["music"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "_id": id,
    "id": aqourId,
    "name": name,
    "date": date,
    "cover_path": List<dynamic>.from(coverPath.map((x) => x)),
    "category": category,
    "music": List<dynamic>.from(music.map((x) => x)),
  };
}

class Music {
  Music({
    required this.s,
    required this.aqours,
    required this.nijigasaki,
    required this.liella,
    required this.combine,
  });

  List<MusicAqour> s;
  List<MusicAqour> aqours;
  List<MusicAqour> nijigasaki;
  List<MusicAqour> liella;
  List<MusicAqour> combine;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    s: List<MusicAqour>.from(json["μ's"].map((x) => MusicAqour.fromJson("μ's",x))),
    aqours: List<MusicAqour>.from(json["Aqours"].map((x) => MusicAqour.fromJson("Aqours",x))),
    nijigasaki: List<MusicAqour>.from(json["Nijigasaki"].map((x) => MusicAqour.fromJson("Nijigasaki",x))),
    liella: List<MusicAqour>.from(json["Liella!"].map((x) => MusicAqour.fromJson("Liella!",x))),
    combine: List<MusicAqour>.from(json["Combine"].map((x) => MusicAqour.fromJson("Combine",x))),
  );

  Map<String, dynamic> toJson() => {
    "μ's": List<dynamic>.from(s.map((x) => x.toJson())),
    "Aqours": List<dynamic>.from(aqours.map((x) => x.toJson())),
    "Nijigasaki": List<dynamic>.from(nijigasaki.map((x) => x.toJson())),
    "Liella!": List<dynamic>.from(liella.map((x) => x.toJson())),
    "Combine": List<dynamic>.from(combine.map((x) => x.toJson())),
  };
}

class MusicAqour {
  MusicAqour({
    required this.type,
    required this.id,
    required this.aqourId,
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
  String type;
  String id;
  int aqourId;
  String name;
  int album;
  String coverPath;
  String musicPath;
  String artist;
  String artistBin;
  String time;
  String lyric;
  String trans;
  String roma;
  String albumName;

  factory MusicAqour.fromJson(String key,Map<String, dynamic> json) => MusicAqour(
    type: key,
    id: json["_id"],
    aqourId: json["id"],
    name: json["name"],
    album: json["album"],
    coverPath: json["cover_path"],
    musicPath: json["music_path"],
    artist: json["artist"],
    artistBin: json["artist_bin"],
    time: json["time"],
    lyric: json["lyric"],
    trans: json["trans"] ?? "",
    roma: json["roma"],
    albumName: json["albumName"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "_id": id,
    "id": aqourId,
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

