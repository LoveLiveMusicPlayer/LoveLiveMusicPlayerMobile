import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/global/global_theme.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/CloudData.dart';
import 'package:lovelivemusicplayer/models/CloudUpdate.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/modules/pageview/logic.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:lovelivemusicplayer/widgets/reset_data_dialog.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
        children: [
          topView(),
          groupView(),
          functionView(context),
          SizedBox(height: 6.h),
          versionView(),
        ],
      ),
    ));
  }

  Widget topView() {
    return Column(
      children: [
        Obx(() {
          final photoPath =
              global.getCurrentGroupIcon(global.currentGroup.value);
          Widget widget;
          if (photoPath == Assets.logoLogo) {
            widget = SvgPicture.asset(
              Assets.logoSvgLogo,
              width: 165.h,
              height: 165.h,
              fit: BoxFit.fitWidth,
            );
          } else {
            widget = logoIcon(photoPath,
                hasShadow: false,
                width: 120,
                height: 120,
                radius: 120,
                color: Colors.transparent);
          }
          return SizedBox(
            height: 130.h,
            child: widget,
          );
        }),
        Text("LoveLiveMusicPlayer",
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h)
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
              global.currentGroup.value = Const.groupAll;
              DBLogic.to.findAllListByGroup(Const.groupAll);
            }),
            showGroupButton(Assets.drawerLogoUs, onTap: () {
              global.currentGroup.value = Const.groupUs;
              DBLogic.to.findAllListByGroup(Const.groupUs);
            }),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showGroupButton(Assets.drawerLogoAqours, onTap: () {
              global.currentGroup.value = Const.groupAqours;
              DBLogic.to.findAllListByGroup(Const.groupAqours);
            }),
            showGroupButton(Assets.drawerLogoNijigasaki, onTap: () {
              global.currentGroup.value = Const.groupSaki;
              DBLogic.to.findAllListByGroup(Const.groupSaki);
            })
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showGroupButton(Assets.drawerLogoLiella, onTap: () {
              global.currentGroup.value = Const.groupLiella;
              DBLogic.to.findAllListByGroup(Const.groupLiella);
            }),
            showGroupButton(Assets.drawerLogoAllstars, onTap: () {
              global.currentGroup.value = Const.groupCombine;
              DBLogic.to.findAllListByGroup(Const.groupCombine);
            }),
          ],
        ),
        SizedBox(height: 16.h)
      ],
    );
  }

  Widget functionView(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Container(
            width: 250.w,
            margin: EdgeInsets.only(left: 8.w, right: 8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                    color: Get.isDarkMode
                        ? ColorMs.color05080C.withAlpha(16)
                        : Colors.white,
                    offset: Offset(-3.w, -3.h),
                    blurStyle: BlurStyle.inner,
                    blurRadius: 6.r),
                BoxShadow(
                    color: Get.isDarkMode
                        ? ColorMs.color05080C
                        : ColorMs.colorD3E0EC,
                    offset: Offset(5.w, 3.h),
                    blurRadius: 6.r),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: scrollView(context),
            )));
  }

  Widget scrollView(BuildContext context) {
    return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(() {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DrawerFunctionButton(
                icon: Assets.drawerDrawerQuickTrans,
                text: 'music_trans'.tr,
                onTap: () async {
                  Get.back();
                  Get.toNamed(Routes.routeTransform);
                },
              ),
              SizedBox(height: 8.h),
              DrawerFunctionButton(
                icon: Assets.drawerDrawerDataSync,
                text: 'data_sync'.tr,
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.routeDataSync);
                },
              ),
              SizedBox(height: 8.h),
              DrawerFunctionButton(
                  icon: Assets.drawerDrawerSystemTheme,
                  text: 'theme_with_system'.tr,
                  hasSwitch: true,
                  initSwitch: GlobalLogic.to.withSystemTheme.value,
                  callBack: (check) async {
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
                icon: Assets.drawerDrawerDataDownload,
                text: 'fetch_songs'.tr,
                onTap: () {
                  handleUpdateData();
                },
              ),
              SizedBox(height: 8.h),
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
                      // Get.deleteAll(force: true);
                      // Phoenix.rebirth(Get.context!);
                      // Get.reset();
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
                    SmartDialog.compatible
                        .showToast('clean_success'.tr, time: const Duration(seconds: 5));
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
                icon: Assets.drawerDrawerUpdate,
                text: 'update'.tr,
                onTap: () {
                  GlobalLogic.to.checkUpdate(manual: true);
                },
              ),
              SizedBox(height: 8.h),
              DrawerFunctionButton(
                icon: Assets.drawerDrawerSecret,
                text: 'privacy_agreement'.tr,
                onTap: () {
                  Get.toNamed(Routes.routePermission);
                },
              )
            ],
          );
        }));
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

  handleUpdateData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int currentNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
    SmartDialog.compatible.showLoading(msg: 'downloading'.tr);
    Network.get(Const.dataUrl, success: (result) {
      if (result is List) {
        int index = -1;
        int maxNumber = 0;
        for (var i = 0; i < result.length; i++) {
          final map = CloudUpdate.fromJson(result[i]);
          if (currentNumber > maxNumber && currentNumber <= map.maxVersion) {
            maxNumber = map.maxVersion;
            index = i;
          }
        }
        if (index == -1) {
          return;
        }
        String latestDataUrl = CloudUpdate.fromJson(result[index]).url;
        Network.dio?.request(latestDataUrl).then((value) {
          CloudData data = CloudData.fromJson(value.data);
          SpUtil.getInt(Const.spDataVersion).then((currentVersion) {
            if (currentVersion == data.version) {
              SmartDialog.compatible.dismiss(status: SmartStatus.loading);
              SmartDialog.compatible.show(
                  widget: TwoButtonDialog(
                title: 'now_is_latest'.tr,
                isShowMsg: false,
                onConfirmListener: () {
                  SmartDialog.compatible
                      .dismiss(status: SmartStatus.allDialog)
                      .then((value) {
                    parseUpdateDataSource(data);
                  });
                },
              ));
            } else if (currentVersion < data.version) {
              SmartDialog.compatible
                  .dismiss(status: SmartStatus.loading)
                  .then((value) {
                parseUpdateDataSource(data);
              });
            }
          });
        });
      } else {
        SmartDialog.compatible.dismiss(status: SmartStatus.loading);
        SmartDialog.compatible.showToast('data_error'.tr);
      }
    }, error: (err) {
      Log4f.e(msg: err, writeFile: true);
      SmartDialog.compatible.dismiss(status: SmartStatus.loading);
      SmartDialog.compatible.showToast('fetch_songs_fail'.tr);
    }, isShowDialog: false, isShowError: false);
  }

  parseUpdateDataSource(CloudData data) async {
    SmartDialog.compatible.showLoading(msg: 'importing'.tr);
    await DBLogic.to.clearAllMusic();
    await loopParseData(data.music.us, data.album.us, Const.groupUs);
    await loopParseData(
        data.music.aqours, data.album.aqours, Const.groupAqours);
    await loopParseData(
        data.music.nijigasaki, data.album.nijigasaki, Const.groupSaki);
    await loopParseData(
        data.music.liella, data.album.liella, Const.groupLiella);
    await loopParseData(
        data.music.combine, data.album.combine, Const.groupCombine);
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
    SmartDialog.compatible.dismiss(status: SmartStatus.loading);
    SpUtil.put(Const.spDataVersion, data.version);
  }

  Future<void> loopParseData(List<InnerMusic> musicList,
      List<InnerAlbum> albumList, String group) async {
    await Future.forEach<InnerMusic>(musicList, (music) async {
      if (music.export && checkFileExist(music)) {
        int albumId = music.albumId;
        InnerAlbum album = albumList.firstWhere((album) => album.id == albumId);
        DownloadMusic downloadMusic = DownloadMusic(
            albumUId: album.albumUId,
            albumId: albumId,
            albumName: album.name,
            coverPath: music.coverPath,
            date: album.date,
            category: album.category,
            group: group,
            musicUId: music.musicUId,
            musicId: music.id,
            musicName: music.name,
            musicPath: music.musicPath,
            artist: music.artist,
            artistBin: music.artistBin,
            totalTime: music.time,
            baseUrl: music.baseUrl);
        await DBLogic.to.importMusic(downloadMusic);
      }
    });
  }

  Widget versionView() {
    return SizedBox(
        height: 30.h,
        child: Center(
          child: Text("Ver.$appVersion"),
        ));
  }

  bool checkFileExist(InnerMusic music) {
    if (Platform.isIOS) {
      music.musicPath = music.musicPath.replaceAll(".flac", ".wav");
    }
    return File('${SDUtils.path}${music.baseUrl}${music.musicPath}')
        .existsSync();
  }
}
