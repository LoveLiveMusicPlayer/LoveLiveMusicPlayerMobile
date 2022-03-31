import 'dart:convert';

import 'package:floor/floor.dart';

class StringListConverter extends TypeConverter<List<String>?, String> {
  @override
  List<String>? decode(String databaseValue) {
    // return jsonDecode(databaseValue);
    return List<String>.from(json.decode(databaseValue).map((x) => x));
  }

  @override
  String encode(List<String>? databaseValue) {
    return json.encode(List<String>.from(databaseValue?.map((x) => x) ?? []));
  }
}