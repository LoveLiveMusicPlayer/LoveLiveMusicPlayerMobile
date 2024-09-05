import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:sharesdk_plugin/sharesdk_interface.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:umeng_push_sdk/umeng_push_sdk.dart';

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

  static initSDK() {
    UmengPushSdk.setLogEnable(true);
    UmengCommonSdk.initCommon(
        '634bd9c688ccdf4b7e4ac67b', '634bdfd305844627b56670a1', 'Umeng');
    UmengCommonSdk.setPageCollectionModeManual();
    SharesdkPlugin.uploadPrivacyPermissionStatus(1, (success) {});

    if (Platform.isAndroid) {
      UmengPushSdk.setTokenCallback((deviceToken) {
        AppUtils.isPre(() => print("deviceToken: $deviceToken"));
      });
    }

    UmengPushSdk.setNotificationCallback((receive) {}, (open) {
      final json = jsonDecode(open);
      final data = json["data"];
      Get.toNamed(Routes.routeDaily, arguments: data);
    });

    agree().then((value) {
      UmengPushSdk.register("5f69a20ba246501b677d0923", "IOS");
      UmengPushSdk.getRegisteredId().then((deviceToken) {
        AppUtils.isPre(() => print("deviceToken: $deviceToken"));
      });
    });
  }
}
