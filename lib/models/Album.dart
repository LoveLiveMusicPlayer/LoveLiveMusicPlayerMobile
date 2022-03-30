import 'dart:convert';

AlbumData musicFromJson(String str) => AlbumData.fromJson(json.decode(str));

String musicToJson(AlbumData data) => json.encode(data.toJson());

class AlbumData {
  String? uid; //唯一标识
  String? name; //专辑名称
  String? date; //时间
  List<String>? coverPath; //封面
  String? category; //类别
  List<int>? music;

  AlbumData(
      {this.uid,
      this.name,
      this.date,
      this.coverPath,
      this.category,
      this.music}); //对应歌曲id

  factory AlbumData.fromJson(Map<String, dynamic> json) => AlbumData(
        uid: json["_id"],
        name: json["name"],
        date: json["date"],
        coverPath: List<String>.from(json["cover_path"].map((x) => x)),
        category: json["category"],
        music: List<int>.from(json["music"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": uid,
        "name": name,
        "date": date,
        "cover_path": List<dynamic>.from(coverPath!.map((x) => x)),
        "category": category,
        "music": List<dynamic>.from(music!.map((x) => x)),
      };
}
