import 'dart:convert';

Music musicFromJson(String str) => Music.fromJson(json.decode(str));

String musicToJson(Music data) => json.encode(data.toJson());

class Music {
  Music({
    required this.name,
    required this.cover,
    required this.singer,
  });

  String name;
  String cover;
  String singer;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    name: json["name"],
    cover: json["cover"],
    singer: json["singer"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "cover": cover,
    "singer": singer,
  };
}
