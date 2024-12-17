import 'dart:async';
import 'dart:io';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/usb_mount.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/sdcard.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/directory_util.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';

class SDCardLogic extends GetxController {
  final sdList = <SdCard>[].obs;
  StreamSubscription? usbMountSub;

  @override
  void onInit() {
    super.onInit();

    refreshUsbDevice();

    usbMountSub = eventBus.on<UsbMount>().listen((event) {
      Future.delayed(const Duration(seconds: 1)).then((v) {
        refreshUsbDevice();
      });
    });

    AppUtils.uploadEvent("SDCard");
  }

  refreshUsbDevice() {
    SDUtils.getUsbPathList().then((pathList) async {
      if (pathList.isEmpty) {
        return;
      }
      final defPath = await SpUtil.getString(Const.spSDPath);
      final tempList = <SdCard>[];
      for (var path in pathList) {
        var key = path.split("/")[2];
        if (key == "emulated") {
          key = 'internal_storage'.tr;
        }
        final isChosen = defPath.contains(path);
        tempList.add(SdCard(name: key, path: path, choose: isChosen));
      }
      sdList.value = tempList;
    });
  }

  click(SdCard item) async {
    final tempList = <SdCard>[];
    for (var sdcard in sdList) {
      final isChoose = sdcard.name == item.name;
      final tempSd =
          SdCard(name: sdcard.name, path: sdcard.path, choose: isChoose);
      tempList.add(tempSd);
      if (isChoose) {
        final isExist = await DirectoryUtil.checkDirectoryExist(tempSd.path);
        if (isExist) {
          await DBLogic.to.clearAllMusicThroughUsb();
          SpUtil.put(Const.spSDPath, tempSd.path + Platform.pathSeparator);
        } else {
          SmartDialog.showToast('storage_not_found'.tr);
          refreshUsbDevice();
        }
      }
    }
    sdList.value = tempList;
    SDUtils.init();
  }

  @override
  void onClose() {
    usbMountSub?.cancel();
    super.onClose();
  }
}
