import 'dart:convert';

Music musicFromJson(String str) => Music.fromJson(json.decode(str));

String musicToJson(Music data) => json.encode(data.toJson());

class Music {
  Music({
    required this.name,
    required this.cover,
  });

  String name;
  String cover;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    name: json["name"],
    cover: json["cover"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "cover": cover,
  };
}
