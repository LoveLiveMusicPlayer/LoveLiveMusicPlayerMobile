import 'dart:convert';

PlayingLyric playingLrcFromJson(String str) =>
    PlayingLyric.fromJson(json.decode(str));

String playingLrcToJson(PlayingLyric data) => json.encode(data.toJson());

class PlayingLyric {
  PlayingLyric({
    this.musicId,
    this.lyricLine1,
    this.lyricLine2,
  });

  String? musicId;
  String? lyricLine1;
  String? lyricLine2;

  factory PlayingLyric.fromJson(Map<String, dynamic> json) => PlayingLyric(
        musicId: json["musicId"],
        lyricLine1: json["lyricLine1"],
        lyricLine2: json["lyricLine2"],
      );

  Map<String, dynamic> toJson() => {
        "musicId": musicId,
        "lyricLine1": lyricLine1,
        "lyricLine2": lyricLine2,
      };
}
