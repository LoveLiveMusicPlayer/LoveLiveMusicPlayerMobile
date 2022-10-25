import 'dart:convert';

InitConfig initConfigFromJson(String str) =>
    InitConfig.fromJson(json.decode(str));

String initConfigToJson(InitConfig data) => json.encode(data.toJson());

class InitConfig {
  InitConfig({
    required this.ossUrl,
    required this.splash,
  });

  String ossUrl;
  Splash splash;

  factory InitConfig.fromJson(Map<String, dynamic> json) => InitConfig(
        ossUrl: json["ossUrl"],
        splash: Splash.fromJson(json["splash"]),
      );

  Map<String, dynamic> toJson() => {
        "ossUrl": ossUrl,
        "splash": splash.toJson(),
      };
}

class Splash {
  Splash({
    required this.route,
    this.forceChoose,
    required this.bg,
  });

  String route;
  dynamic forceChoose;
  List<Bg> bg;

  factory Splash.fromJson(Map<String, dynamic> json) => Splash(
        route: json["route"],
        forceChoose: json["forceChoose"],
        bg: List<Bg>.from(json["bg"].map((x) => Bg.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "route": route,
        "forceChoose": forceChoose,
        "bg": List<dynamic>.from(bg.map((x) => x.toJson())),
      };
}

class Bg {
  Bg({
    required this.uid,
    required this.singer,
    required this.size,
  });

  String uid;
  String singer;
  int size;

  factory Bg.fromJson(Map<String, dynamic> json) => Bg(
        uid: json["uid"],
        singer: json["singer"],
        size: json["size"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "singer": singer,
        "size": size,
      };
}
