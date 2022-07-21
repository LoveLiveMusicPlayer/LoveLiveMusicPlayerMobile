import 'dart:convert';

import 'package:floor/floor.dart';

PlayListMusic albumFromJson(String str) =>
    PlayListMusic.fromJson(json.decode(str));

String albumToJson(PlayListMusic data) => json.encode(data.toJson());

@Entity(tableName: "PlayListMusic")
class PlayListMusic {
  PlayListMusic(
      {required this.musicId,
      required this.musicName,
      required this.artist,
      this.isPlaying = false});

  @primaryKey
  String musicId;
  String musicName;
  String artist;
  bool isPlaying;

  factory PlayListMusic.fromJson(Map<String, dynamic> json) => PlayListMusic(
      musicId: json["musicId"],
      musicName: json["musicName"],
      artist: json["artist"],
      isPlaying: json["isPlaying"]);

  Map<String, dynamic> toJson() => {
        "musicId": musicId,
        "musicName": musicName,
        "artist": artist,
        "isPlaying": isPlaying
      };
}
