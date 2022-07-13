import 'dart:convert';

PlayListMusic albumFromJson(String str) => PlayListMusic.fromJson(json.decode(str));

String albumToJson(PlayListMusic data) => json.encode(data.toJson());

class PlayListMusic {
  PlayListMusic({
    required this.musicId,
    required this.musicName,
    required this.artist,
    this.isPlaying = false
  });

  String musicId;
  String musicName;
  String artist;
  bool isPlaying;

  factory PlayListMusic.fromJson(Map<String, dynamic> json) => PlayListMusic(
    musicId: json["musicId"],
    musicName: json["musicName"],
    artist: json["artist"],
    isPlaying: json["isPlaying"]
  );

  Map<String, dynamic> toJson() => {
    "musicId": musicId,
    "musicName": musicName,
    "artist": artist,
    "isPlaying": isPlaying
  };
}
