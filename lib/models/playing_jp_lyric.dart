import 'dart:convert';

JpLrc jpLrcFromJson(String str) => JpLrc.fromJson(json.decode(str));

String jpLrcToJson(JpLrc data) => json.encode(data.toJson());

class JpLrc {
  JpLrc({
    this.musicId,
    this.pre,
    this.current,
    this.next,
  });

  String? musicId;
  String? pre;
  String? current;
  String? next;

  factory JpLrc.fromJson(Map<String, dynamic> json) => JpLrc(
        musicId: json["musicId"],
        pre: json["pre"],
        current: json["current"],
        next: json["next"],
      );

  Map<String, dynamic> toJson() => {
        "musicId": musicId,
        "pre": pre,
        "current": current,
        "next": next,
      };
}
