import 'dart:convert';

import 'package:floor/floor.dart';

Splash splashFromJson(String str) => Splash.fromJson(json.decode(str));

String splashToJson(Splash data) => json.encode(data.toJson());

@Entity(tableName: "Splash")
class Splash {
  Splash({
    required this.url,
  });

  @primaryKey
  String url;

  factory Splash.fromJson(Map<String, dynamic> json) => Splash(
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
  };
}
