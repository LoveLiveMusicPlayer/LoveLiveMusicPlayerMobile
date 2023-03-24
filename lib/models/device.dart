import 'dart:convert';

Device deviceFromJson(String str) => Device.fromJson(json.decode(str));

String deviceToJson(Device data) => json.encode(data.toJson());

class Device {
  Device(
      {required this.physicalDevice,
      required this.serialNo,
      required this.brand,
      required this.model,
      required this.osName,
      required this.osVersion});

  bool physicalDevice;
  String serialNo;
  String brand;
  String model;
  String osName;
  String osVersion;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        physicalDevice: json["physicalDevice"],
        serialNo: json["serialNo"],
        brand: json["brand"],
        model: json["model"],
        osName: json["osName"],
        osVersion: json["osVersion"],
      );

  Map<String, dynamic> toJson() => {
        "physicalDevice": physicalDevice,
        "serialNo": serialNo,
        "brand": brand,
        "model": model,
        "osName": osName,
        "osVersion": osVersion,
      };
}
