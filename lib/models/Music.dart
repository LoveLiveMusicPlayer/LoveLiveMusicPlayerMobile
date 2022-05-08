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
    this.group,
    this.isLove = false,
    this.isPlaying = false,
    this.index = 0
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
  bool isLove; // 是否我喜欢
  String? group; // 团组
  bool isPlaying; // 是否当前播放
  int index; // 处于播放器播放列表第几首

  factory Music.fromJson(Map<String, dynamic> json) => Music(
    uid: json["_id"],
    name: json["name"],
    coverPath: json["cover_path"],
    musicPath: json["music_path"],
    artist: json["artist"],
    artistBin: json["artist_bin"],
    totalTime: json["time"],
    jpUrl: json["lyric"],
    zhUrl: json["trans"],
    romaUrl: json["roma"],
    isLove: json["isLove"] == 1 ? true : false,
    group: json["group"],
    isPlaying: json["isPlaying"] == 1 ? true : false,
  );

  Map<String, dynamic> toJson() => {
    "_id": uid,
    "name": name,
    "cover_path": coverPath,
    "music_path": musicPath,
    "artist": artist,
    "artist_bin": artistBin,
    "time": totalTime,
    "lyric": jpUrl,
    "trans": zhUrl,
    "roma": romaUrl,
    "isLove": isLove ? 1 : 0,
    "group": group,
    "isPlaying": isPlaying ? 1 : 0,
  };
}
