import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:synchronized/synchronized.dart';

class SpUtil {
  static SpUtil? _singleton;
  static GetStorage? _sp;
  static final Lock _lock = Lock();

  static SpUtil getInstance() {
    if (_singleton == null) {
      _lock.synchronized(() {
        if (_singleton == null) {
          var singleton = SpUtil._();
          singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton!;
  }

  SpUtil._();

  _init() {
    _sp = GetStorage();
  }

  static Future<bool> put(String key, Object value) async {
    if (value is int || value is String || value is double) {
      await _sp?.write(key, value);
      return true;
    } else if (value is bool) {
      await _sp?.write(key, value ? 1 : 0);
      return true;
    } else {
      await _sp?.write(key, jsonEncode(value));
      return true;
    }
  }

  static Future<int> getInt(String key, [int defValue = 0]) async {
    final value = await _sp?.read(key);
    if (value is int) {
      return value;
    } else {
      return defValue;
    }
  }

  static Future<String> getString(String key, [String defValue = ""]) async {
    final value = await _sp?.read(key);
    if (value is String) {
      return value;
    } else {
      return defValue;
    }
  }

  static Future<double> getDouble(String key, [double defValue = 0]) async {
    final value = await _sp?.read(key);
    if (value is double) {
      return value;
    } else {
      return defValue;
    }
  }

  static Future<bool> getBoolean(String key, [bool defValue = false]) async {
    final value = await _sp?.read(key);
    if (value is int) {
      return value == 1;
    } else {
      return defValue;
    }
  }

  static Future<dynamic> getObj(String key) async {
    final str = await _sp?.read(key);
    if (str is String) {
      final res = jsonDecode(str);
      if (res is List) {
        return res;
      } else if (res is Object) {
        return res;
      }
    }
    return List.empty(growable: true);
  }

  static Future<Map> getMap(String key) async {
    final res = await _sp?.read(key) ?? {};
    return jsonDecode(res);
  }

  static bool hasKey(String key) {
    return _sp?.hasData(key) ?? false;
  }

  static Set<String>? getKeys() {
    return _sp?.getKeys();
  }

  static remove(String key) async {
    await _sp?.remove(key);
  }

  static clear() async {
    await _sp?.erase();
  }

  static bool isInitialized() {
    return _sp != null;
  }
}
