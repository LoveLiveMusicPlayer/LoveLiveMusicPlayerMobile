import 'package:talker_flutter/talker_flutter.dart';

class Log4f {
  static Talker? logcat;

  static Talker getLogger() {
    logcat ??= TalkerFlutter.init();
    return logcat!;
  }

  static v({required String msg}) {
    logcat?.verbose(msg);
  }

  static d({required String msg}) {
    logcat?.debug(msg);
  }

  static i({required String msg}) {
    logcat?.info(msg);
  }

  static w({required String msg}) {
    logcat?.warning(msg);
  }

  static e({required String msg}) {
    logcat?.error(msg);
  }

  /// GetX 日志重定向
  static void defaultLogWriterCallback(String value, {bool isError = false}) {
    if (isError && !value.contains("already removed")) {
      Log4f.i(msg: value);
    }
  }
}
