import 'dart:collection';
import 'dart:convert';

List<ArtistModel> artistFromJson(String str) => List<ArtistModel>.from(
    json.decode(str).map((x) => ArtistModel.fromJson(x)));

String artistToJson(List<ArtistModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArtistModel extends LinkedListEntry<ArtistModel> {
  ArtistModel({required this.k, required this.v, this.m});

  String k;
  String v;
  String? m;

  factory ArtistModel.fromJson(Map<String, dynamic> json) => ArtistModel(
        k: json["k"],
        v: json["v"],
        m: json["m"],
      );

  Map<String, dynamic> toJson() => {
        "k": k,
        "v": v,
        "m": m,
      };
}
