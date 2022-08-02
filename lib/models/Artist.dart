import 'dart:convert';

Artist artistFromJson(String str) => Artist.fromJson(json.decode(str));

String artistToJson(Artist data) => json.encode(data.toJson());

class Artist {
  Artist({
    required this.name,
    required this.artistBin,
    required this.photo,
    required this.count
  });

  String name;
  String artistBin;
  String photo;
  int count;

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
        name: json["name"],
        artistBin: json["artistBin"],
        photo: json["photo"],
        count: json["count"]
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "artistBin": artistBin,
        "photo": photo,
        "count": count
      };
}
