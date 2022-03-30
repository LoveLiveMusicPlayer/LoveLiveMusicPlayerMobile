import 'dart:convert';

Music musicFromJson(String str) => Music.fromJson(json.decode(str));

String musicToJson(Music data) => json.encode(data.toJson());

class Music {
  Music({
    this.uid,
    this.name,
    this.albumId,
    this.albumName,
    this.coverPath,
    this.musicPath,
    this.artist,
    this.artistBin,
    this.totalTime,
    this.jpUrl,
    this.zhUrl,
    this.romaUrl,
    this.preJPLrc = "はすんだ！",
    this.currentJPLrc = "だから僕らは鳴らすんだ！",
    this.nextJPLrc = "だか鳴ららはすんだ！",
    this.isPlaying = false,
    this.isLove = false,
  });
  /// 实体层属性
  String? uid; // id
  String? name; // 歌名
  String? albumId; // 专辑id
  String? albumName; // 专辑名
  String? coverPath; // 封面路径
  String? musicPath; // 歌曲路径
  String? artist; // 歌手
  String? artistBin; // 歌手32进制数据
  String? totalTime; // 时长
  String? jpUrl; // 日文歌词 URL
  String? zhUrl; // 中文歌词 URL
  String? romaUrl; // 罗马音歌词 URL
  bool isLove; // 我喜欢

  /// 业务层属性
  bool isPlaying; // 正在播放
  // todo: 不放在这里
  String? preJPLrc;
  String? currentJPLrc;
  String? nextJPLrc;

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    uid: json["uid"],
    name: json["name"],
    coverPath: json["coverPath"],
    musicPath: json["musicPath"],
    artist: json["artist"],
    artistBin: json["artistBin"],
    totalTime: json["totalTime"],

    jpUrl: json["jpUrl"],
    zhUrl: json["zhUrl"],
    romaUrl: json["romaUrl"],

    preJPLrc: json["preJPLrc"],
    currentJPLrc: json["currentJPLrc"],
    nextJPLrc: json["nextJPLrc"],

    isPlaying: json["isPlaying"],
    isLove: json["isLove"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "coverPath": coverPath,
    "musicPath": musicPath,
    "artist": artist,
    "artistBin": artistBin,
    "totalTime": totalTime,

    "jpUrl": jpUrl,
    "zhUrl": zhUrl,
    "romaUrl": romaUrl,

    "preJPLrc": preJPLrc,
    "currentJPLrc": currentJPLrc,
    "nextJPLrc": nextJPLrc,

    "isPlaying": isPlaying,
    "isLove": isLove,
  };
}
