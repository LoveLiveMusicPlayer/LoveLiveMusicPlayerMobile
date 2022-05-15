import 'dart:convert';

import 'package:floor/floor.dart';

import '../models/Music.dart';

class StringListConverter extends TypeConverter<List<String>?, String> {
  @override
  List<String>? decode(String databaseValue) {
    return List<String>.from(json.decode(databaseValue).map((x) => x));
  }

  @override
  String encode(List<String>? value) {
    return json.encode(List<String>.from(value?.map((x) => x) ?? []));
  }
}

class MusicListConverter extends TypeConverter<List<Music>, String> {
  @override
  List<Music> decode(String databaseValue) {
    return List<Music>.from(
        json.decode(databaseValue).map((x) => musicFromJson(x)));
  }

  @override
  String encode(List<Music> value) {
    return json.encode(value.map((x) => musicToJson(x)).toList());
  }
}
