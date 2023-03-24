import 'dart:convert';

import 'package:floor/floor.dart';

History historyFromJson(String str) => History.fromJson(json.decode(str));

String historyToJson(History data) => json.encode(data.toJson());

@Entity(tableName: "History")
class History {
  History({
    required this.musicId,
    required this.timestamp,
  });

  @primaryKey
  String musicId;
  int timestamp;

  factory History.fromJson(Map<String, dynamic> json) => History(
        musicId: json["musicId"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "musicId": musicId,
        "timestamp": timestamp,
      };
}
