import 'package:flutter/foundation.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:lovelivemusicplayer/utils/sentry_util.dart';

class FlutterErrorReport {
  static Future<void> reportErrorAndLog(FlutterErrorDetails details) async {
    final errorStr = details.exceptionAsString();
    if (errorStr
        .contains("ScrollController not attached to any scroll views")) {
      return;
    }
    final errorMsg = {
      "exception": errorStr,
      "stackTrace": details.stack.toString(),
    };
    if (kDebugMode) {
      Log4f.i(msg: "$errorMsg");
    } else {
      SentryUtil.getInstance().exception(errorMsg);
    }
  }

  static FlutterErrorDetails makeDetails(Object error, StackTrace stackTrace) {
    // 构建错误信息
    return FlutterErrorDetails(stack: stackTrace, exception: error);
  }
}
