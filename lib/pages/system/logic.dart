import 'dart:convert';
import 'dart:io';

import 'package:croppy/croppy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/http_server.dart';
import 'package:lovelivemusicplayer/utils/image_util.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/dialog_add_min.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:lovelivemusicplayer/widgets/reset_data_dialog.dart';
import 'package:lovelivemusicplayer/widgets/text_field_dialog.dart';

class SystemSettingLogic extends GetxController {
  final scrollViewWithTachiHeight = Get.height - 210.h;
  final scrollViewWithoutTachiHeight = Get.height - 390.h;
  late double maxHeight;
  ButtonController? darkModeController;

  @override
  void onInit() {
    setMaxHeight(GlobalLogic.to.hasSkin.value);
    GlobalLogic.to.timerController ??=
        ButtonController('timed_to_stop'.tr, false);
    super.onInit();
    startServer();
  }

  setMaxHeight(bool isColorfulMode) {
    maxHeight = isColorfulMode
        ? scrollViewWithoutTachiHeight
        : scrollViewWithTachiHeight;
  }

  enableFollowSystemMode(bool isEnable) async {
    // 获取当前系统主题色
    bool isDark =
        MediaQuery.of(Get.context!).platformBrightness == Brightness.dark;
    if (isEnable) {
      // 设置为系统主题色
      AppUtils.changeTheme(isDark);
    } else {
      // 设置为原来手动设置的主题色
      AppUtils.changeTheme(GlobalLogic.to.manualIsDark.value);
    }

    // 将全局变量设置为所选值
    GlobalLogic.to.withSystemTheme.value = isEnable;
    if (isEnable) {
      // 如果跟随系统
      if (GlobalLogic.to.manualIsDark.value != isDark) {
        darkModeController?.setSwitchValue = isDark;
        GlobalLogic.to.manualIsDark.value = isDark;
      }
    }
    // 修改sp值
    await SpUtil.put(Const.spWithSystemTheme, isEnable);
    await SpUtil.put(Const.spDark, isDark);
    GlobalLogic.to.isThemeDark();

    // 恢复原来操作的界面
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      Get.forceAppUpdate().then((value) {
        PageViewLogic.to.controller
            .jumpToPage(HomeController.to.state.currentIndex.value);
      });
    });
  }

  changeDayOrNightMode(bool isNightMode) async {
    AppUtils.changeTheme(isNightMode);
    if (GlobalLogic.to.hasSkin.value &&
        PlayerLogic.to.playingMusic.value.musicId == null) {
      GlobalLogic.to.iconColor.value = const Color(Const.noMusicColorfulSkin);
    }
    // 将全局变量设置为所选值
    GlobalLogic.to.manualIsDark.value = isNightMode;
    // 修改sp值
    await SpUtil.put(Const.spDark, isNightMode);
    GlobalLogic.to.isThemeDark();
    // 恢复原来操作的界面
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      Get.forceAppUpdate().then((value) {
        PageViewLogic.to.controller
            .jumpToPage(HomeController.to.state.currentIndex.value);
      });
    });
  }

  changeColorfulMode(bool isColorfulMode) async {
    setMaxHeight(isColorfulMode);
    if (isColorfulMode) {
      startServer();
    }
    // 将全局变量设置为所选值
    GlobalLogic.to.hasSkin.value = isColorfulMode;
    // 修改sp值
    await SpUtil.put(Const.spColorful, isColorfulMode);
    if (GlobalLogic.to.hasSkin.value &&
        PlayerLogic.to.playingMusic.value.musicId == null) {
      GlobalLogic.to.iconColor.value = const Color(Const.noMusicColorfulSkin);
    }
  }

  enableSplashPhoto(bool isEnable) {
    SpUtil.put(Const.spAIPicture, isEnable);
    GlobalLogic.to.hasAIPic = isEnable;
  }

  enableBackgroundPhoto(bool isEnable) {
    GlobalLogic.to.enableBG = isEnable;
    SpUtil.put(Const.spEnableBackgroundPhoto, isEnable);
    if (isEnable) {
      SpUtil.getString(Const.spBackgroundPhoto).then((value) {
        final filePath = SDUtils.bgPhotoPath + value;
        if (SDUtils.checkFileExist(filePath)) {
          GlobalLogic.to.setBgPhoto(filePath);
        }
      });
    } else {
      GlobalLogic.to.setBgPhoto("");
    }
  }

  chooseBackgroundPhoto() async {
    if (GlobalLogic.to.enableBG) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      final cropImage = await showCupertinoImageCropper(
        Get.context!,
        locale: Get.locale,
        allowedAspectRatios: [
          CropAspectRatio(width: Get.width.toInt(), height: Get.height.toInt()),
        ],
        imageProvider:
            FileImage(File(image.path)), // Or any other image provider
      );

      final picContent = await ImageUtil.imageToBytes(cropImage?.uiImage);
      if (picContent == null) {
        return;
      }

      final fileName = "${DateTime.now()}.jpg";
      SDUtils.saveBGPhoto(fileName, picContent);
    } else {
      SmartDialog.showToast('need_enable_bg'.tr);
    }
  }

  enableRemoteHttp(bool isEnable) {
    GlobalLogic.to.remoteHttp.setEnableHttp(isEnable);
  }

  showInputHttpUrlDialog(ButtonController controller) {
    SmartDialog.show(
        clickMaskDismiss: false,
        alignment: Alignment.center,
        builder: (context) {
          return TextFieldDialog(
              title: 'input_http_url'.tr,
              hint: 'support_http_characters'.tr,
              controller: TextEditingController(
                  text: GlobalLogic.to.remoteHttp.httpUrl.value),
              maxLength: 50,
              formatter: [
                FilteringTextInputFormatter.allow(
                    RegExp('^[a-zA-Z0-9.:/_-]*\$'))
              ],
              onConfirm: (host) async {
                if (host.isEmpty) {
                  controller.setTextValue = 'input_http_url'.tr;
                  await GlobalLogic.to.remoteHttp.setHttpUrl("");
                } else {
                  host = host.endsWith("/") ? host : "$host/";
                  controller.setTextValue = host;
                  await GlobalLogic.to.remoteHttp.setHttpUrl(host);
                }
              });
        });
  }

  showShutdownTimerDialog() {
    SmartDialog.show(
        clickMaskDismiss: false,
        alignment: Alignment.center,
        builder: (context) {
          return AddMinDialog(
            title: 'select_time'.tr,
            initTimer: GlobalLogic.to.remainTime.value,
            onConfirmListener: ([number]) {
              GlobalLogic.to.startTimer(number);
            },
          );
        });
  }

  showClearDatabaseDialog() {
    SmartDialog.show(builder: (context) {
      return ResetDataDialog(deleteMusicData: () async {
        SpUtil.remove(Const.spDataVersion);
        await DBLogic.to.clearAllMusic();
      }, deleteUserData: () async {
        await DBLogic.to.clearAllUserData();
        await AppUtils.cacheManager.emptyCache();
        SDUtils.clearBGPhotos();
        SmartDialog.dismiss();
        SpUtil.put(Const.spAllowPermission, true).then((value) async {
          SmartDialog.dismiss();
          SmartDialog.showLoading(msg: 'will_shutdown'.tr);
          Future.delayed(const Duration(seconds: 2), () {
            if (Platform.isIOS) {
              exit(0);
            } else {
              SystemNavigator.pop();
            }
          });
        });
      }, afterDelete: () async {
        SmartDialog.dismiss();
        SmartDialog.showToast('clean_success'.tr,
            animationTime: const Duration(seconds: 5));
        await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
      });
    });
  }

  Future<Map<String, Color?>> getShowAsset() async {
    final manifestJson = await DefaultAssetBundle.of(Get.context!)
        .loadString('AssetManifest.json');
    final images = json.decode(manifestJson).keys.where(
        (String key) => key.startsWith('assets/role/') && key.endsWith(".png"));
    List<String> assets = [];
    assets.addAll(images);
    assets.shuffle();
    final assetPath = assets.first;
    Color? color = await AppUtils.getImagePalette2(assetPath);
    return {assetPath: color};
  }

  startServer() {
    MyHttpServer.startServer();
  }

  @override
  void onClose() {
    MyHttpServer.stopServer();
    super.onClose();
  }
}
