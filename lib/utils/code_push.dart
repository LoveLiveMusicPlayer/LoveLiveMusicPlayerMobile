import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:synchronized/synchronized.dart';

final shorebirdCodePush = ShorebirdCodePush();

class CodePush {
  static CodePush? _singleton;
  static final Lock _lock = Lock();

  static CodePush getInstance() {
    if (_singleton == null) {
      _lock.synchronized(() {
        if (_singleton == null) {
          var singleton = CodePush._();
          _singleton = singleton;
        }
      });
    }
    return _singleton!;
  }

  CodePush._();

  final currentPatchNumber = shorebirdCodePush.currentPatchNumber();

  Future<bool> hasNewVersion() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return await shorebirdCodePush.isNewPatchAvailableForDownload();
  }

  Future<void> upgrade() async {
    SmartDialog.compatible.showLoading(msg: 'upgrading'.tr);
    await shorebirdCodePush.downloadUpdateIfAvailable();
    bool isDownloadOK = await shorebirdCodePush.isNewPatchReadyToInstall();
    SmartDialog.compatible.dismiss();
    if (isDownloadOK) {
      SmartDialog.compatible.showToast('upgrade_on_next_time'.tr);
    }
  }
}
