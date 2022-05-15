import 'dart:convert';

BizType bizTypeFromJson(String str) => BizType.fromJson(json.decode(str));

String bizTypeToJson(BizType data) => json.encode(data.toJson());

class BizType {
  BizType({
    required this.key,
    required this.value,
    required this.orgId,
    this.config,
  });

  String key;
  String value;
  int orgId;
  String? config;

  factory BizType.fromJson(Map<String, dynamic> json) => BizType(
        key: json["key"],
        value: json["value"],
        orgId: json["orgId"],
        config: json["config"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
        "orgId": orgId,
        "config": config,
      };
}
