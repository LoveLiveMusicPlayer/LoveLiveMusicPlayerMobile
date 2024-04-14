import 'dart:convert';
import 'dart:io';

import 'package:croppy/croppy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/global/global_theme.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/image_util.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/dialog_add_min.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:lovelivemusicplayer/widgets/reset_data_dialog.dart';
import 'package:lovelivemusicplayer/widgets/tachie_widget.dart';
import 'package:lovelivemusicplayer/widgets/text_field_dialog.dart';

class SystemSettings extends StatefulWidget {
  const SystemSettings({super.key});

  @override
  State<SystemSettings> createState() => _SystemSettingsState();
}

class _SystemSettingsState extends State<SystemSettings> {
  final scrollViewWithTachiHeight = Get.height - 210.h;
  final scrollViewWithoutTachiHeight = Get.height - 390.h;
  late double maxHeight;
  ButtonController? darkModeController;

  @override
  void initState() {
    GlobalLogic.to.timerController ??=
        ButtonController('timed_to_stop'.tr, false);
    darkModeController =
        ButtonController('night_mode'.tr, GlobalLogic.to.manualIsDark.value);
    maxHeight = GlobalLogic.to.hasSkin.value
        ? scrollViewWithoutTachiHeight
        : scrollViewWithTachiHeight;
    super.initState();
    startServer();
  }

  @override
  void dispose() {
    stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder<bool>(
                  valueListenable: GlobalLogic.mobileWeSlideController,
                  builder:
                      (BuildContext context, bool isOpened, Widget? child) {
                    return Visibility(
                      visible: !isOpened,
                      maintainState: true,
                      child: const Tachie(),
                    );
                  }),
            ),
            Column(
              children: [
                DetailsHeader(title: 'system_settings'.tr),
                SizedBox(height: 16.h),
                Container(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: SingleChildScrollView(
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: renderTopFunctionButtonArray()),
                      SizedBox(height: 2.h),
                      renderRoleLogo(),
                      SizedBox(height: 2.h),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: renderBottomFunctionButtonArray())
                    ]),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget renderTopFunctionButtonArray() {
    return GetBuilder<GlobalLogic>(builder: (logic) {
      final iconColor = logic.bgPhoto.value == "" ? null : ColorMs.colorCCCCCC;
      return Column(
        children: [
          DrawerFunctionButton(
              icon: Assets.drawerDrawerSystemTheme,
              iconColor: iconColor,
              text: 'theme_with_system'.tr,
              hasSwitch: true,
              initSwitch: GlobalLogic.to.withSystemTheme.value,
              callBack: (controller, check) async {
                // 获取当前系统主题色
                bool isDark = MediaQuery.of(context).platformBrightness ==
                    Brightness.dark;
                if (check) {
                  // 设置为系统主题色
                  Get.changeThemeMode(
                      isDark ? ThemeMode.dark : ThemeMode.light);
                  Get.changeTheme(isDark ? darkTheme : lightTheme);
                } else {
                  // 设置为原来手动设置的主题色
                  Get.changeThemeMode(GlobalLogic.to.manualIsDark.value
                      ? ThemeMode.dark
                      : ThemeMode.light);
                  Get.changeTheme(GlobalLogic.to.manualIsDark.value
                      ? darkTheme
                      : lightTheme);
                }

                // 将全局变量设置为所选值
                GlobalLogic.to.withSystemTheme.value = check;
                if (check) {
                  // 如果跟随系统
                  if (GlobalLogic.to.manualIsDark.value != isDark) {
                    darkModeController?.setSwitchValue = isDark;
                    GlobalLogic.to.manualIsDark.value = isDark;
                  }
                }
                // 修改sp值
                await SpUtil.put(Const.spWithSystemTheme, check);
                await SpUtil.put(Const.spDark, isDark);
                GlobalLogic.to.isThemeDark();

                // 恢复原来操作的界面
                Future.delayed(const Duration(milliseconds: 300)).then((value) {
                  Get.forceAppUpdate().then((value) {
                    PageViewLogic.to.controller
                        .jumpToPage(HomeController.to.state.currentIndex.value);
                  });
                });
              }),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
              icon: Assets.drawerDrawerDayNight,
              iconColor: iconColor,
              hasSwitch: true,
              controller: darkModeController,
              enableSwitch: !GlobalLogic.to.withSystemTheme.value,
              callBack: (controller, check) async {
                Get.changeThemeMode(check ? ThemeMode.dark : ThemeMode.light);
                Get.changeTheme(check ? darkTheme : lightTheme);
                if (GlobalLogic.to.hasSkin.value &&
                    PlayerLogic.to.playingMusic.value.musicId == null) {
                  GlobalLogic.to.iconColor.value =
                      const Color(Const.noMusicColorfulSkin);
                }
                // 将全局变量设置为所选值
                GlobalLogic.to.manualIsDark.value = check;
                // 修改sp值
                await SpUtil.put(Const.spDark, check);
                GlobalLogic.to.isThemeDark();
                // 恢复原来操作的界面
                Future.delayed(const Duration(milliseconds: 300)).then((value) {
                  Get.forceAppUpdate().then((value) {
                    PageViewLogic.to.controller
                        .jumpToPage(HomeController.to.state.currentIndex.value);
                  });
                });
              }),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
              icon: Assets.drawerDrawerColorful,
              iconColor: iconColor,
              text: 'colorful_mode'.tr,
              hasSwitch: true,
              initSwitch: GlobalLogic.to.hasSkin.value,
              callBack: (controller, check) async {
                setState(() {
                  maxHeight = check
                      ? scrollViewWithoutTachiHeight
                      : scrollViewWithTachiHeight;
                });
                if (check) {
                  startServer();
                }
                // 将全局变量设置为所选值
                GlobalLogic.to.hasSkin.value = check;
                // 修改sp值
                await SpUtil.put(Const.spColorful, check);
                if (GlobalLogic.to.hasSkin.value &&
                    PlayerLogic.to.playingMusic.value.musicId == null) {
                  GlobalLogic.to.iconColor.value =
                      const Color(Const.noMusicColorfulSkin);
                }
              }),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
              icon: Assets.drawerDrawerAiPic,
              iconColor: iconColor,
              text: 'splash_photo'.tr,
              hasSwitch: true,
              initSwitch: hasAIPic,
              callBack: (controller, check) async {
                SpUtil.put(Const.spAIPicture, check);
                hasAIPic = check;
              }),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
              icon: Assets.drawerDrawerBackground,
              iconColor: iconColor,
              text: 'enable_background_photo'.tr,
              hasSwitch: true,
              initSwitch: enableBG,
              callBack: (controller, check) async {
                enableBG = check;
                SpUtil.put(Const.spEnableBackgroundPhoto, check);
                if (check) {
                  SpUtil.getString(Const.spBackgroundPhoto).then((value) {
                    if (SDUtils.checkFileExist(SDUtils.bgPhotoPath + value)) {
                      GlobalLogic.to.setBgPhoto(SDUtils.bgPhotoPath + value);
                    }
                  });
                } else {
                  GlobalLogic.to.setBgPhoto("");
                }
              }),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
            text: 'choose_background_photo'.tr,
            iconColor: iconColor,
            onTap: (controller) async {
              if (enableBG) {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image == null) {
                  return;
                }
                final cropImage = await showCupertinoImageCropper(
                  Get.context!,
                  locale: Get.locale,
                  allowedAspectRatios: [
                    CropAspectRatio(
                        width: Get.width.toInt(), height: Get.height.toInt()),
                  ],
                  imageProvider: FileImage(
                      File(image.path)), // Or any other image provider
                );

                final picContent =
                    await ImageUtil.imageToBytes(cropImage?.uiImage);
                if (picContent == null) {
                  return;
                }

                final fileName = "${DateTime.now()}.jpg";
                SDUtils.saveBGPhoto(fileName, picContent);
              } else {
                SmartDialog.showToast('need_enable_bg'.tr);
              }
            },
          ),
          SizedBox(height: 8.h),
          ListenableBuilder(
              listenable:
                  Listenable.merge([remoteHttp.enableHttp, remoteHttp.httpUrl]),
              builder: (c, w) {
                return DrawerFunctionButton(
                    icon: Assets.drawerDrawerHttp,
                    iconColor: iconColor,
                    text: 'use_http_music'.tr,
                    enableSwitch: remoteHttp.httpUrl.value.isNotEmpty,
                    hasSwitch: true,
                    initSwitch: remoteHttp.isEnableHttp(),
                    callBack: (controller, check) async {
                      await remoteHttp.setEnableHttp(check);
                    });
              }),
          SizedBox(height: 8.h),
          ListenableBuilder(
              listenable:
                  Listenable.merge([remoteHttp.enableHttp, remoteHttp.httpUrl]),
              builder: (c, w) {
                final text = remoteHttp.noneHttpUrl()
                    ? 'input_http_url'.tr
                    : remoteHttp.httpUrl.value;
                return DrawerFunctionButton(
                  text: text,
                  iconColor: iconColor,
                  onTap: (controller) {
                    SmartDialog.show(
                        clickMaskDismiss: false,
                        alignment: Alignment.center,
                        builder: (context) {
                          return TextFieldDialog(
                              title: 'input_http_url'.tr,
                              hint: 'support_http_characters'.tr,
                              controller: TextEditingController(
                                  text: remoteHttp.httpUrl.value),
                              maxLength: 50,
                              formatter: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('^[a-zA-Z0-9.:/_-]*\$'))
                              ],
                              onConfirm: (host) async {
                                if (host.isEmpty) {
                                  controller.setTextValue = 'input_http_url'.tr;
                                  await remoteHttp.setHttpUrl("");
                                } else {
                                  host = host.endsWith("/") ? host : "$host/";
                                  controller.setTextValue = host;
                                  await remoteHttp.setHttpUrl(host);
                                }
                              });
                        });
                  },
                );
              }),
        ],
      );
    });
  }

  Widget renderBottomFunctionButtonArray() {
    return GetBuilder<GlobalLogic>(builder: (logic) {
      final iconColor = logic.bgPhoto.value == "" ? null : ColorMs.colorCCCCCC;
      return Column(
        children: [
          DrawerFunctionButton(
            icon: Assets.drawerDrawerTimer,
            iconColor: iconColor,
            controller: logic.timerController,
            onTap: (controller) {
              SmartDialog.show(
                  clickMaskDismiss: false,
                  alignment: Alignment.center,
                  builder: (context) {
                    return AddMinDialog(
                      title: 'select_time'.tr,
                      initTimer: logic.remainTime.value,
                      onConfirmListener: ([number]) {
                        logic.startTimer(number);
                      },
                    );
                  });
            },
          ),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
            icon: Assets.drawerDrawerReset,
            iconColor: iconColor,
            text: 'clear_database'.tr,
            onTap: (controller) {
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
                  await DBLogic.to
                      .findAllListByGroup(GlobalLogic.to.currentGroup.value);
                });
              });
            },
          ),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
            icon: Assets.drawerDrawerInspect,
            iconColor: iconColor,
            text: 'view_log'.tr,
            onTap: (controller) async {
              Get.toNamed(Routes.routeLogger);
            },
          ),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
            icon: Assets.drawerDrawerSecret,
            iconColor: iconColor,
            text: 'privacy_agreement'.tr,
            onTap: (controller) {
              Get.toNamed(Routes.routePermission);
            },
          )
        ],
      );
    });
  }

  Widget renderRoleLogo() {
    return FutureBuilder<Map<String, Color?>>(
      initialData: const {"": Colors.transparent},
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, Color?>> snapshot) {
        final assetPath = snapshot.data?.keys.first;
        final dotColor = snapshot.data?.values.first?.withAlpha(255);
        if (assetPath != null && assetPath.isNotEmpty) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 7.r,
                  height: 7.r,
                  color: dotColor,
                ),
              ),
              SizedBox(
                width: 35.w,
              ),
              ClipOval(
                child: Container(
                  width: 9.r,
                  height: 9.r,
                  color: dotColor,
                ),
              ),
              SizedBox(
                width: 35.w,
              ),
              Image.asset(
                snapshot.data?.keys.first ?? "",
                width: 32.r,
                height: 32.r,
              ),
              SizedBox(
                width: 35.w,
              ),
              ClipOval(
                child: Container(
                  width: 9.r,
                  height: 9.r,
                  color: dotColor,
                ),
              ),
              SizedBox(
                width: 35.w,
              ),
              ClipOval(
                child: Container(
                  width: 7.r,
                  height: 7.r,
                  color: dotColor,
                ),
              )
            ],
          );
        } else {
          return SizedBox(
            height: 32.r,
          );
        }
      },
      future: getShowAsset(),
    );
  }

  Future<Map<String, Color?>> getShowAsset() async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final images = json.decode(manifestJson).keys.where(
        (String key) => key.startsWith('assets/role/') && key.endsWith(".png"));
    List<String> assets = [];
    assets.addAll(images);
    assets.shuffle();
    final assetPath = assets.first;
    Color? color = await AppUtils.getImagePalette2(assetPath);
    return {assetPath: color};
  }
}
