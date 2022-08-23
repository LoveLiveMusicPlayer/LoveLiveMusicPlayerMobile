import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_theme.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  final global = Get.find<GlobalLogic>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [topView(), groupView(), functionView(context)],
      ),
    ));
  }

  Widget topView() {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Obx(() {
          return logoIcon(global.getCurrentGroupIcon(global.currentGroup.value),
              width: 96, height: 96, radius: 96);
        }),
        SizedBox(height: 12.h),
        Text("LoveLiveMusicPlayer",
            style: TextStyle(fontSize: 17.sp, color: const Color(0xFF333333))),
        SizedBox(height: 20.h)
      ],
    );
  }

  Widget groupView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showGroupButton(Assets.drawerLogoLovelive, onTap: () {
              global.currentGroup.value = "all";
              DBLogic.to.findAllListByGroup("all");
            }, innerWidth: 107, innerHeight: 27),
            showGroupButton(Assets.drawerLogoUs, onTap: () {
              global.currentGroup.value = "μ's";
              DBLogic.to.findAllListByGroup("μ's");
            }, innerWidth: 74, innerHeight: 58),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showGroupButton(Assets.drawerLogoAqours, onTap: () {
              global.currentGroup.value = "Aqours";
              DBLogic.to.findAllListByGroup("Aqours");
            }, innerWidth: 90, innerHeight: 36),
            showGroupButton(Assets.drawerLogoNijigasaki, onTap: () {
              global.currentGroup.value = "Nijigasaki";
              DBLogic.to.findAllListByGroup("Nijigasaki");
            }, innerWidth: 101, innerHeight: 40)
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showGroupButton(Assets.drawerLogoLiella, onTap: () {
              global.currentGroup.value = "Liella!";
              DBLogic.to.findAllListByGroup("Liella!");
            }, innerWidth: 100, innerHeight: 35),
            showGroupButton(Assets.drawerLogoAllstars, onTap: () {
              global.currentGroup.value = "Combine";
              DBLogic.to.findAllListByGroup("Combine");
            }, innerWidth: 88, innerHeight: 44),
          ],
        ),
        SizedBox(height: 20.h)
      ],
    );
  }

  Widget functionView(BuildContext context) {
    return ListTile(
        title: Container(
        width: 270.w,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8.w),
          boxShadow: [
            BoxShadow(
                color: Get.isDarkMode
                    ? const Color(0x1005080C)
                    : Colors.white,
                offset: Offset(-3.w, -3.h),
                blurStyle: BlurStyle.inner,
                blurRadius: 6.w),
            BoxShadow(
                color: Get.isDarkMode
                    ? const Color(0xFF05080C)
                    : const Color(0xFFD3E0EC),
                offset: Offset(5.w, 3.h),
                blurRadius: 6.w),
          ],
        ),
        child: scrollView()
    ));
  }

  Widget scrollView() {
    return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Obx(() {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                  icon: Assets.drawerDrawerQuickTrans,
                  text: "歌曲快传",
                  onTap: () async {
                    Get.back();
                    var data = await Get.toNamed(Routes.routeScan);
                    if (data != null) {
                      Get.toNamed(Routes.routeTransform, arguments: data);
                    }
                  },
                ),
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                  icon: Assets.drawerDrawerDataSync,
                  text: "数据同步",
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.routeDataSync);
                  },
                ),
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                    icon: Assets.drawerDrawerSystemTheme,
                    text: "跟随系统主题",
                    hasSwitch: true,
                    initSwitch: GlobalLogic.to.withSystemTheme.value,
                    callBack: (check) async {
                      // 获取当前系统主题色
                      bool isDark =
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark;
                      if (check) {
                        // 设置为系统主题色
                        Get.changeTheme(isDark ? darkTheme : lightTheme);
                      } else {
                        // 设置为原来手动设置的主题色
                        Get.changeTheme(GlobalLogic.to.manualIsDark.value
                            ? darkTheme
                            : lightTheme);
                      }
                      // 将全局变量设置为所选值
                      GlobalLogic.to.withSystemTheme.value = check;
                      // 修改sp值
                      await SpUtil.put(Const.spWithSystemTheme, check);
                      // 恢复原来操作的界面
                      Future.delayed(const Duration(milliseconds: 500))
                          .then((value) {
                        PageViewLogic.to.controller.jumpToPage(
                            HomeController.to.state.currentIndex.value);
                      });
                    }),
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                    icon: Assets.drawerDrawerDayNight,
                    text: "夜间模式",
                    hasSwitch: true,
                    initSwitch: GlobalLogic.to.manualIsDark.value,
                    enableSwitch: !GlobalLogic.to.withSystemTheme.value,
                    callBack: (check) async {
                      Get.changeTheme(check ? darkTheme : lightTheme);
                      // 将全局变量设置为所选值
                      GlobalLogic.to.manualIsDark.value = check;
                      // 修改sp值
                      await SpUtil.put(Const.spDark, check);
                      // 恢复原来操作的界面
                      Future.delayed(const Duration(milliseconds: 500))
                          .then((value) {
                        PageViewLogic.to.controller.jumpToPage(
                            HomeController.to.state.currentIndex.value);
                      });
                    }),
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                    icon: Assets.drawerDrawerColorful,
                    text: "炫彩主题(高性能)",
                    hasSwitch: true,
                    initSwitch: GlobalLogic.to.hasSkin.value,
                    callBack: (check) async {
                      // 将全局变量设置为所选值
                      GlobalLogic.to.hasSkin.value = check;
                      // 修改sp值
                      await SpUtil.put(Const.spColorful, check);
                    }),
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                  icon: Assets.drawerDrawerSecret,
                  text: "关于和隐私",
                  onTap: () {},
                ),
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                  icon: Assets.drawerDrawerReset,
                  text: "清理数据",
                  onTap: () async {
                    SmartDialog.compatible
                        .showLoading(msg: "重置中...", backDismiss: false);
                    await DBLogic.to.clearAllAlbum();
                    await DBLogic.to.findAllListByGroup(
                        GlobalLogic.to.currentGroup.value);
                    SmartDialog.dismiss();
                    SmartDialog.compatible.showToast("清理成功",
                        time: const Duration(seconds: 5));
                  },
                ),
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                  icon: Assets.drawerDrawerDebug,
                  text: "保存日志",
                  onTap: () async {
                    await SDUtils.uploadLog();
                    SmartDialog.compatible.showToast("导出成功",
                        time: const Duration(seconds: 5));
                  },
                ),
                SizedBox(height: 8.h),
                DrawerFunctionButton(
                  icon: Assets.drawerDrawerInspect,
                  text: "查看日志",
                  onTap: () async {
                    Get.toNamed(Routes.routeLogger);
                  },
                ),
                SizedBox(height: 8.h),
              ],
            );
          }),
        )
    );
  }
}
