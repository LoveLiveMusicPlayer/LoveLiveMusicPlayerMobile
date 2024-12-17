import 'dart:convert';

SdCard sdCardFromJson(String str) => SdCard.fromJson(json.decode(str));

String sdCardToJson(SdCard data) => json.encode(data.toJson());

class SdCard {
  String name;
  String path;
  bool choose;

  SdCard({
    required this.name,
    required this.path,
    required this.choose,
  });

  factory SdCard.fromJson(Map<String, dynamic> json) => SdCard(
        name: json["name"],
        path: json["path"],
        choose: json["choose"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "path": path,
        "choose": choose,
      };
}
