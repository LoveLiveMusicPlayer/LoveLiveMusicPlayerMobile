import 'dart:convert';

PlayingLyric playingLrcFromJson(String str) =>
    PlayingLyric.fromJson(json.decode(str));

String playingLrcToJson(PlayingLyric data) => json.encode(data.toJson());

class PlayingLyric {
  PlayingLyric({
    this.musicId,
    this.current,
    this.next,
  });

  String? musicId;
  String? current;
  String? next;

  factory PlayingLyric.fromJson(Map<String, dynamic> json) => PlayingLyric(
        musicId: json["musicId"],
        current: json["current"],
        next: json["next"],
      );

  Map<String, dynamic> toJson() => {
        "musicId": musicId,
        "current": current,
        "next": next,
      };
}
