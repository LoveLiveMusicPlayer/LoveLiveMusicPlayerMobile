import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_update.dart';
import 'package:lovelivemusicplayer/models/group.dart';
import 'package:lovelivemusicplayer/modules/drawer/logic.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';

class DrawerLayout extends GetView<DrawerLogic> {
  const DrawerLayout({super.key});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Get.isDarkMode ? ColorMs.colorNightPrimary : Colors.white;
    return Drawer(
        backgroundColor: bgColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => topView()),
              SizedBox(height: 16.h),
              groupView(),
              SizedBox(height: 16.h),
              functionView(context),
              SizedBox(height: 6.h),
              versionView(),
            ],
          ),
        ));
  }

  Widget topView() {
    final currentLogo = controller.getLogo(GlobalLogic.to.currentGroup.value);
    final diameter = currentLogo == Assets.logoLogo ? 165.h : 120.0;
    final textColor = Get.isDarkMode ? ColorMs.colorEDF5FF : Colors.black;
    return Column(
      children: [
        SizedBox(
            height: 130.h,
            child: logoIcon(
              currentLogo,
              color: Colors.transparent,
              width: diameter,
              height: diameter,
              radius: diameter,
              hasShadow: false,
            )),
        Text("LoveLiveMusicPlayer",
            style: TextStyle(fontSize: 17.h, color: textColor)),
      ],
    );
  }

  Widget groupView() {
    return Column(
      children: [
        renderItem(GroupKey.groupAll, GroupKey.groupUs),
        SizedBox(height: 12.h),
        renderItem(GroupKey.groupAqours, GroupKey.groupNijigasaki),
        SizedBox(height: 12.h),
        renderItem(GroupKey.groupLiella, GroupKey.groupHasunosora),
        SizedBox(height: 12.h),
        renderItem(GroupKey.groupYohane, GroupKey.groupCombine),
      ],
    );
  }

  Widget renderItem(GroupKey groupLeft, GroupKey? groupRight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        showGroupButton(groupLeft.getDrawable(),
            onTap: () => controller.refreshList(groupLeft)),
        Visibility(
          visible: groupRight != null,
          maintainAnimation: true,
          maintainSize: true,
          maintainState: true,
          child: showGroupButton(groupRight!.getDrawable(),
              onTap: () => controller.refreshList(groupRight)),
        )
      ],
    );
  }

  Widget functionView(BuildContext context) {
    final bColor = Get.isDarkMode ? ColorMs.colorNightPrimary : Colors.white;
    final sColor = Get.isDarkMode ? ColorMs.color05080C : ColorMs.colorEEEEEE;
    return Expanded(
        flex: 1,
        child: Container(
            width: 250.w,
            margin: EdgeInsets.only(left: 8.w, right: 8.w),
            decoration: BoxDecoration(
              color: bColor,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                    color: sColor, offset: Offset(5.w, 3.h), blurRadius: 6.r),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: scrollView(),
                  )),
            )));
  }

  List<Widget> scrollView() {
    return [
      DrawerFunctionButton(
        icon: Assets.drawerDrawerCalendar,
        text: "daily_news".tr,
        colorWithBG: false,
        onTap: (controller) {
          Get.back();
          Get.toNamed(Routes.routeDaily);
        },
      ),
      SizedBox(height: 8.h),
      DrawerFunctionButton(
        icon: Assets.drawerDrawerQuickTrans,
        text: 'music_trans'.tr,
        colorWithBG: false,
        onTap: (controller) async {
          Get.back();
          Get.toNamed(Routes.routeTransform);
        },
      ),
      SizedBox(height: 8.h),
      DrawerFunctionButton(
        icon: Assets.drawerDrawerDataSync,
        text: 'data_sync'.tr,
        colorWithBG: false,
        onTap: (controller) {
          Get.back();
          Get.toNamed(Routes.routeDataSync);
        },
      ),
      SizedBox(height: 8.h),
      DrawerFunctionButton(
        icon: Assets.drawerDrawerDataDownload,
        text: 'fetch_songs'.tr,
        colorWithBG: false,
        onTap: (_) => controller.handleUpdateData(),
      ),
      SizedBox(height: 8.h),
      DrawerFunctionButton(
        icon: Assets.drawerDrawerUpdate,
        text: 'update'.tr,
        colorWithBG: false,
        onTap: (_) => UpdateLogic.to.checkUpdate(),
      ),
      SizedBox(height: 8.h),
      DrawerFunctionButton(
        icon: Assets.drawerDrawerCar,
        text: "drive_mode".tr,
        colorWithBG: false,
        onTap: (controller) {
          Get.back();
          Get.toNamed(Routes.routeDriveMode);
        },
      ),
      SizedBox(height: 8.h),
      DrawerFunctionButton(
        icon: Assets.drawerDrawerSetting,
        text: 'system_settings'.tr,
        colorWithBG: false,
        onTap: (controller) {
          Get.back();
          Get.toNamed(Routes.routeSystemSettings, id: 1);
        },
      ),
      SizedBox(height: 8.h),
      DrawerFunctionButton(
        icon: Assets.drawerDrawerShare,
        text: "share".tr,
        colorWithBG: false,
        onTap: (controller) {
          Get.back();
          AppUtils.shareQQ();
        },
      )
    ];
  }

  Widget versionView() {
    final version = GlobalLogic.to.appVersion;
    final isPre = GlobalLogic.to.env == "pre";
    final style = Get.isDarkMode ? TextStyleMs.white_12 : TextStyleMs.black_12;
    return SizedBox(
        height: 24.h,
        child: Center(
          child: Text("Ver.$version${isPre ? " Preview" : ""}", style: style),
        ));
  }
}
