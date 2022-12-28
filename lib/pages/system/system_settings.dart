import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
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
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:lovelivemusicplayer/widgets/reset_data_dialog.dart';

class SystemSettings extends StatefulWidget {
  const SystemSettings({Key? key}) : super(key: key);

  @override
  State<SystemSettings> createState() => _SystemSettingsState();
}

class _SystemSettingsState extends State<SystemSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.primaryColor,
        body: Column(children: [
          DetailsHeader(title: 'system_settings'.tr),
          SizedBox(height: 16.h),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  DrawerFunctionButton(
                      icon: Assets.drawerDrawerSystemTheme,
                      text: 'theme_with_system'.tr,
                      hasSwitch: true,
                      initSwitch: GlobalLogic.to.withSystemTheme.value,
                      callBack: (check) async {
                        // 获取当前系统主题色
                        bool isDark =
                            MediaQuery.of(context).platformBrightness ==
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
                        // 修改sp值
                        await SpUtil.put(Const.spWithSystemTheme, check);
                        GlobalLogic.to.isThemeDark();

                        // 恢复原来操作的界面
                        Future.delayed(const Duration(milliseconds: 300))
                            .then((value) {
                          Get.forceAppUpdate().then((value) {
                            PageViewLogic.to.controller.jumpToPage(
                                HomeController.to.state.currentIndex.value);
                          });
                        });
                      }),
                  SizedBox(height: 8.h),
                  renderDayOrNightSwitch(),
                  DrawerFunctionButton(
                      icon: Assets.drawerDrawerColorful,
                      text: 'colorful_mode'.tr,
                      hasSwitch: true,
                      initSwitch: GlobalLogic.to.hasSkin.value,
                      callBack: (check) async {
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
                      text: 'splash_photo'.tr,
                      hasSwitch: true,
                      initSwitch: hasAIPic,
                      callBack: (check) async {
                        SpUtil.put(Const.spAIPicture, check);
                      }),
                  SizedBox(height: 8.h),
                  DrawerFunctionButton(
                    icon: Assets.drawerDrawerBackground,
                    text: 'setting_background_photo'.tr,
                    onTap: () async {
                      Get.toNamed(Routes.routeLogger);
                    },
                  ),
                ],
              )),
          SizedBox(height: 16.h),
          Divider(height: 1.h, color: const Color.fromARGB(255, 102, 102, 102)),
          SizedBox(height: 16.h),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  DrawerFunctionButton(
                    icon: Assets.drawerDrawerReset,
                    text: 'clear_database'.tr,
                    onTap: () {
                      SmartDialog.compatible.show(
                          widget: ResetDataDialog(deleteMusicData: () async {
                            SpUtil.remove(Const.spDataVersion);
                            await DBLogic.to.clearAllMusic();
                          }, deleteUserData: () async {
                            await DBLogic.to.clearAllUserData();
                            AppUtils.cacheManager.emptyCache();
                            SpUtil.put(Const.spAllowPermission, true)
                                .then((value) async {
                              SmartDialog.compatible.dismiss();
                              SmartDialog.compatible.showToast('will_shutdown'.tr);
                              Future.delayed(const Duration(seconds: 2), () {
                                if (Platform.isIOS) {
                                  exit(0);
                                } else {
                                  SystemNavigator.pop();
                                }
                              });
                            });
                          }, afterDelete: () async {
                            SmartDialog.compatible.dismiss();
                            SmartDialog.compatible.showToast('clean_success'.tr,
                                time: const Duration(seconds: 5));
                            await DBLogic.to
                                .findAllListByGroup(GlobalLogic.to.currentGroup.value);
                          }));
                    },
                  ),
                  // SizedBox(height: 8.h),
                  // DrawerFunctionButton(
                  //   icon: Assets.drawerDrawerDebug,
                  //   text: "保存日志",
                  //   onTap: () async {
                  //     await SDUtils.uploadLog();
                  //     SmartDialog.compatible
                  //         .showToast("导出成功", time: const Duration(seconds: 5));
                  //   },
                  // ),
                  SizedBox(height: 8.h),
                  DrawerFunctionButton(
                    icon: Assets.drawerDrawerInspect,
                    text: 'view_log'.tr,
                    onTap: () async {
                      Get.toNamed(Routes.routeLogger);
                    },
                  ),
                  SizedBox(height: 8.h),
                  DrawerFunctionButton(
                    icon: Assets.drawerDrawerSecret,
                    text: 'privacy_agreement'.tr,
                    onTap: () {
                      Get.toNamed(Routes.routePermission);
                    },
                  ),
                ],
              ))
        ]));
  }

  Widget renderDayOrNightSwitch() {
    if (GlobalLogic.to.withSystemTheme.value) {
      return Container();
    }
    return Column(
      children: [
        DrawerFunctionButton(
            icon: Assets.drawerDrawerDayNight,
            text: 'night_mode'.tr,
            hasSwitch: true,
            initSwitch: GlobalLogic.to.manualIsDark.value,
            enableSwitch: !GlobalLogic.to.withSystemTheme.value,
            callBack: (check) async {
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
        SizedBox(height: 8.h)
      ],
    );
  }
}
