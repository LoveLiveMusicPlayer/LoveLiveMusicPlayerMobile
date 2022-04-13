import 'dart:convert';
import 'Music.dart';

Artist artistFromJson(String str) => Artist.fromJson(json.decode(str));

String artistToJson(Artist data) => json.encode(data.toJson());

class Artist {
  Artist({
    required this.name,
    required this.artistBin,
    required this.photo,
    required this.music,
  });

  String name;
  String artistBin;
  String photo;
  List<Music> music;

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
    name: json["name"],
    artistBin: json["artistBin"],
    photo: json["photo"],
    music: List<Music>.from(json["music"].map((x) => Music.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "artistBin": artistBin,
    "photo": photo,
    "music": List<dynamic>.from(music.map((x) => x.toJson())),
  };
}