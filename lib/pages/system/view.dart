import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/pages/system/logic.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:lovelivemusicplayer/widgets/header.dart';
import 'package:lovelivemusicplayer/widgets/tachie_widget.dart';

class SystemSettingsPage extends GetView<SystemSettingLogic> {
  const SystemSettingsPage({super.key});

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
                  builder: (_, bool isOpened, __) {
                    return Visibility(
                      visible: !isOpened,
                      maintainState: true,
                      child: const Tachie(),
                    );
                  }),
            ),
            Column(
              children: [
                AppHeader(title: 'system_settings'.tr),
                SizedBox(height: 16.h),
                Obx(() {
                  return Container(
                    constraints:
                        BoxConstraints(maxHeight: controller.maxHeight.value),
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
                  );
                })
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
              callBack: (_, check) => controller.enableFollowSystemMode(check)),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
              icon: Assets.drawerDrawerColorful,
              iconColor: iconColor,
              text: 'colorful_mode'.tr,
              hasSwitch: true,
              initSwitch: GlobalLogic.to.hasSkin.value,
              callBack: (_, check) => controller.changeColorfulMode(check)),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
              icon: Assets.drawerDrawerAiPic,
              iconColor: iconColor,
              text: 'splash_photo'.tr,
              hasSwitch: true,
              initSwitch: GlobalLogic.to.hasAIPic,
              callBack: (_, check) => controller.enableSplashPhoto(check)),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
            icon: Assets.drawerDrawerDesktopLyric,
            iconColor: iconColor,
            hasSwitch: true,
            controller: GlobalLogic.to.lyricController,
            initSwitch: GlobalLogic.to.lyricController.getSwitchValue,
            callBack: (_, check) => controller.openDesktopLyric(check),
          ),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
              icon: Assets.drawerDrawerBackground,
              iconColor: iconColor,
              text: 'enable_background_photo'.tr,
              hasSwitch: true,
              initSwitch: GlobalLogic.to.enableBG,
              callBack: (_, check) => controller.enableBackgroundPhoto(check)),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
            text: 'choose_background_photo'.tr,
            iconColor: iconColor,
            onTap: (_) => controller.chooseBackgroundPhoto(),
          ),
          SizedBox(height: 8.h),
          ListenableBuilder(
              listenable: Listenable.merge([
                GlobalLogic.to.remoteHttp.enableHttp,
                GlobalLogic.to.remoteHttp.httpUrl
              ]),
              builder: (c, w) {
                return DrawerFunctionButton(
                    icon: Assets.drawerDrawerHttp,
                    iconColor: iconColor,
                    text: 'use_http_music'.tr,
                    enableSwitch:
                        GlobalLogic.to.remoteHttp.httpUrl.value.isNotEmpty,
                    hasSwitch: true,
                    initSwitch: GlobalLogic.to.remoteHttp.isEnableHttp(),
                    callBack: (_, check) => controller.enableRemoteHttp(check));
              }),
          SizedBox(height: 8.h),
          ListenableBuilder(
              listenable: Listenable.merge([
                GlobalLogic.to.remoteHttp.enableHttp,
                GlobalLogic.to.remoteHttp.httpUrl
              ]),
              builder: (c, w) {
                final text = GlobalLogic.to.remoteHttp.noneHttpUrl()
                    ? 'input_http_url'.tr
                    : GlobalLogic.to.remoteHttp.httpUrl.value;
                return DrawerFunctionButton(
                  text: text,
                  iconColor: iconColor,
                  onTap: (ctl) => controller.showInputHttpUrlDialog(ctl),
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
          FutureBuilder<List<String>>(
              future: SDUtils.getUsbPathList(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null &&
                    snapshot.data!.length > 1) {
                  return Column(
                    children: [
                      DrawerFunctionButton(
                        icon: Assets.drawerDrawerSd,
                        iconColor: iconColor,
                        text: 'storage_settings'.tr,
                        onTap: (_) => Get.toNamed(Routes.routeSD),
                      ),
                      SizedBox(height: 8.h)
                    ],
                  );
                }
                return SizedBox.shrink();
              }),
          DrawerFunctionButton(
            icon: Assets.drawerDrawerTimer,
            iconColor: iconColor,
            controller: logic.timerController,
            onTap: (_) => controller.showShutdownTimerDialog(),
          ),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
              icon: Assets.drawerDrawerReset,
              iconColor: iconColor,
              text: 'clear_database'.tr,
              onTap: (_) => controller.showClearDatabaseDialog()),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
            icon: Assets.drawerDrawerInspect,
            iconColor: iconColor,
            text: 'view_log'.tr,
            onTap: (_) => Get.toNamed(Routes.routeLogger),
          ),
          SizedBox(height: 8.h),
          DrawerFunctionButton(
            icon: Assets.drawerDrawerSecret,
            iconColor: iconColor,
            text: 'privacy_agreement'.tr,
            onTap: (_) => Get.toNamed(Routes.routePermission),
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
              renderClipOval(7.r, dotColor),
              SizedBox(width: 35.w),
              renderClipOval(9.r, dotColor),
              SizedBox(width: 35.w),
              Image.asset(snapshot.data?.keys.first ?? "",
                  width: 32.r, height: 32.r),
              SizedBox(width: 35.w),
              renderClipOval(9.r, dotColor),
              SizedBox(width: 35.w),
              renderClipOval(7.r, dotColor),
            ],
          );
        } else {
          return SizedBox(height: 32.r);
        }
      },
      future: controller.getShowAsset(),
    );
  }

  Widget renderClipOval(double diameter, Color? dotColor) {
    return ClipOval(
      child: Container(
        width: diameter,
        height: diameter,
        color: dotColor,
      ),
    );
  }
}
