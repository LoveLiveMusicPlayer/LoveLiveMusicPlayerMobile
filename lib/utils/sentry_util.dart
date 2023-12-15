import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:synchronized/synchronized.dart';

class SentryUtil {
  static SentryUtil? _singleton;
  static final Lock _lock = Lock();

  static SentryUtil getInstance() {
    if (_singleton == null) {
      _lock.synchronized(() {
        if (_singleton == null) {
          var singleton = SentryUtil._();
          _singleton = singleton;
        }
      });
    }
    return _singleton!;
  }

  SentryUtil._();

  Future<void> init() async {
    await SentryFlutter.init(
          (options) {
        options.dsn = Const.sentryUrl;
        options.environment = env;
      },
    );
    await upOpenApp();
  }
  
  exception(dynamic error) {
    Sentry.captureException(error);
  }

  upReportPlaySong(String name, int count, String during) {
    Sentry.captureMessage(
      "play-song-info",
      withScope: (scope) {
        scope.setTag('t-name', name);
        scope.setTag('t-count', "$count");
        scope.setTag('t-during', during);
      },
    );
  }

  upOpenApp() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String? identity;
    if (Platform.isIOS) {
      final info = await deviceInfoPlugin.iosInfo;
      identity = info.identifierForVendor;
    } else if (Platform.isAndroid) {
      final info = await deviceInfoPlugin.androidInfo;
      identity = info.model;
    }
    if (identity == null) {
      return;
    }
    Sentry.captureMessage(
      "open",
      withScope: (scope) {
        scope.setTag('identity', identity!);
      },
    );
  }
}