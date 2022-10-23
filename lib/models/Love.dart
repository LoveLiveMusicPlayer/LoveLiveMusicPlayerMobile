import 'dart:convert';

import 'package:floor/floor.dart';

Love loveFromJson(String str) => Love.fromJson(json.decode(str));

String loveToJson(Love data) => json.encode(data.toJson());

@Entity(tableName: "Love")
class Love {
  Love({
    required this.timestamp,
    required this.musicId
  });

  @primaryKey
  String musicId;
  int timestamp;

  factory Love.fromJson(Map<String, dynamic> json) => Love(
    timestamp: json["timestamp"],
    musicId: json["musicId"]
  );

  Map<String, dynamic> toJson() => {
    "timestamp": timestamp,
    "musicId": musicId
  };
}
