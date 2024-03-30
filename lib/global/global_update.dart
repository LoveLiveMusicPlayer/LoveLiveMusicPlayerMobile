import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_update/flutter_app_update.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:open_appstore/open_appstore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  static const MethodChannel _updateChannel = MethodChannel("android/update");

  static UpdateLogic get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    AzhonAppUpdate.listener((Map<String, dynamic> map) {
      if (map.containsKey('error')) {
        SmartDialog.showToast('update_fail'.tr);
      }
    });
  }

  checkUpdate() async {
    final connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      return;
    }
    if (Platform.isIOS) {
      Network.get(Const.appstoreUrl, success: (resp) async {
        Map<String, dynamic> map = jsonDecode(resp);
        final tempList = map["results"] as List;
        for (var bundle in tempList) {
          final packageInfo = await PackageInfo.fromPlatform();
          if (bundle["bundleId"] == packageInfo.packageName) {
            bool needUpdate =
                AppUtils.compareVersion(packageInfo.version, bundle["version"]);
            if (needUpdate) {
              OpenAppstore.launch(
                  androidAppId: packageInfo.packageName,
                  iOSAppId: "1641625393");
            } else {
              SmartDialog.showToast('no_need_update'.tr);
            }
            break;
          }
        }
      });
    } else {
      Network.get(Const.updateUrl, success: (map) async {
        final isNewVersion =
            AppUtils.compareVersion(appVersion, map['versionName']);
        if (!isNewVersion) {
          SmartDialog.showToast('no_need_update'.tr);
          return;
        }
        showUpdateDialog(map);
      });
    }
  }

  showUpdateDialog(Map<String, dynamic> map) {
    SmartDialog.show(builder: (BuildContext context) {
      return AlertDialog(
        title: Text('发现新版本 v${map['versionName']}'),
        content: Text(map['contentText']),
        actions: <Widget>[
          TextButton(
            child: Text('update_no'.tr),
            onPressed: () {
              SmartDialog.dismiss();
            },
          ),
          TextButton(
            child: Text('update_yes'.tr),
            onPressed: () async {
              SmartDialog.dismiss();
              bool is64Bit = await _updateChannel.invokeMethod("getAbi");
              final model = UpdateModel(
                  is64Bit ? map['64bit_url'] : map['32bit_url'],
                  "update.apk",
                  "ic_launcher",
                  Const.appstoreUrl,
                  apkMD5: is64Bit ? map['64bit_md5'] : map['32bit_md5']);
              AzhonAppUpdate.update(model);
            },
          ),
        ],
      );
    });
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}

  @override
  void dispose() {
    AzhonAppUpdate.dispose();
    super.dispose();
  }
}
