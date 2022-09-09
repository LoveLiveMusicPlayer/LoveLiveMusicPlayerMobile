import 'dart:convert';

List<CloudUpdate> cloudUpdateFromJson(String str) => List<CloudUpdate>.from(
    json.decode(str).map((x) => CloudUpdate.fromJson(x)));

String cloudUpdateToJson(List<CloudUpdate> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CloudUpdate {
  CloudUpdate({
    required this.maxVersion,
    required this.url,
  });

  int maxVersion;
  String url;

  factory CloudUpdate.fromJson(Map<String, dynamic> json) => CloudUpdate(
        maxVersion: json["maxVersion"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "maxVersion": maxVersion,
        "url": url,
      };
}
