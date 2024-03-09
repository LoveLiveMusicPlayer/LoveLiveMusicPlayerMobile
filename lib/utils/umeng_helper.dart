import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class UmengHelper {
  static const MethodChannel _channel = MethodChannel('u-push-helper');

  static Future<void> agree() async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod("agree");
    } else {
      return;
    }
  }

  static Future<bool?> isAgreed() async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod("isAgreed");
    } else {
      return false;
    }
  }
}
