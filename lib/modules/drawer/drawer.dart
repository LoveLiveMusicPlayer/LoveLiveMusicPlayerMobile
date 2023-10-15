import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/cloud_data.dart';
import 'package:lovelivemusicplayer/models/cloud_update.dart';
import 'package:lovelivemusicplayer/models/ftp_music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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
        backgroundColor:
            Get.isDarkMode ? ColorMs.colorNightPrimary : Colors.white,
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
            style: TextStyle(
                fontSize: 17.sp,
                color: Get.isDarkMode ? ColorMs.colorEDF5FF : Colors.black)),
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
            showGroupButton(Assets.drawerLogoHasunosora, onTap: () {
              global.currentGroup.value = Const.groupHasunosora;
              DBLogic.to.findAllListByGroup(Const.groupHasunosora);
            }),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showGroupButton(
                Get.isDarkMode
                    ? Assets.drawerLogoYohaneNight
                    : Assets.drawerLogoYohaneDay, onTap: () {
              global.currentGroup.value = Const.groupYohane;
              DBLogic.to.findAllListByGroup(Const.groupYohane);
            }),
            Visibility(
              visible: true,
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: showGroupButton(Assets.drawerLogoAllstars, onTap: () {
                global.currentGroup.value = Const.groupCombine;
                DBLogic.to.findAllListByGroup(Const.groupCombine);
              }),
            )
          ],
        ),
        SizedBox(height: 16.h),
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
              color: Get.isDarkMode ? ColorMs.colorNightPrimary : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                    color: Get.isDarkMode
                        ? ColorMs.color05080C
                        : ColorMs.colorEEEEEE,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
              onTap: (controller) {
                handleUpdateData();
              },
            ),
            SizedBox(height: 8.h),
            DrawerFunctionButton(
              icon: Assets.drawerDrawerUpdate,
              text: 'update'.tr,
              colorWithBG: false,
              onTap: (controller) {
                if (Platform.isAndroid) {
                  requestInstallPackagesPermission();
                } else {
                  GlobalLogic.to.checkUpdate(manual: true);
                }
              },
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
          ],
        ));
  }

  handleUpdateData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int currentNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
    SmartDialog.showLoading(msg: 'downloading'.tr);
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
        Network.get(latestDataUrl, success: (res) {
          if (res is Map<String, dynamic>) {
            CloudData data = CloudData.fromJson(res);
            SpUtil.getInt(Const.spDataVersion).then((currentVersion) async {
              Log4f.d(msg: "云端版本号: ${data.version}");
              await SmartDialog.dismiss(status: SmartStatus.loading);
              if (currentVersion == data.version) {
                SmartDialog.show(
                    builder: (BuildContext context) => TwoButtonDialog(
                          title: 'now_is_latest'.tr,
                          isShowMsg: false,
                          onConfirmListener: () {
                            parseUpdateDataSource(data);
                          },
                        ));
              } else if (currentVersion < data.version) {
                parseUpdateDataSource(data);
              }
            });
          } else {
            SmartDialog.dismiss(status: SmartStatus.loading);
            SmartDialog.showToast('data_error'.tr);
          }
        }, error: (err) {
          Log4f.i(msg: err);
          SmartDialog.dismiss(status: SmartStatus.loading);
          SmartDialog.showToast('fetch_songs_fail'.tr);
        }, isShowDialog: false);
      } else {
        SmartDialog.dismiss(status: SmartStatus.loading);
        SmartDialog.showToast('data_error'.tr);
      }
    }, error: (err) {
      Log4f.i(msg: err);
      SmartDialog.dismiss(status: SmartStatus.loading);
      SmartDialog.showToast('fetch_songs_fail'.tr);
    }, isShowDialog: false);
  }

  parseUpdateDataSource(CloudData data) async {
    SmartDialog.showLoading(msg: 'importing'.tr);
    await DBLogic.to.clearAllMusic();
    await DBLogic.to.artistDao.deleteAllArtists();
    await loopParseData(data.music.us, data.album.us, Const.groupUs);
    await loopParseData(
        data.music.aqours, data.album.aqours, Const.groupAqours);
    await loopParseData(
        data.music.nijigasaki, data.album.nijigasaki, Const.groupSaki);
    await loopParseData(
        data.music.liella, data.album.liella, Const.groupLiella);
    await loopParseData(
        data.music.combine, data.album.combine, Const.groupCombine);
    await loopParseData(
        data.music.hasunosora, data.album.hasunosora, Const.groupHasunosora);
    await loopParseData(
        data.music.yohane, data.album.yohane, Const.groupYohane);
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
    SmartDialog.dismiss(status: SmartStatus.loading);
    SpUtil.put(Const.spDataVersion, data.version);
  }

  Future<void> loopParseData(List<InnerMusic> musicList,
      List<InnerAlbum> albumList, String group) async {
    await Future.forEach<InnerMusic>(musicList, (music) async {
      if (music.export) {
        int albumId = music.albumId;
        InnerAlbum album = albumList.firstWhere((album) => album.id == albumId);
        music.musicPath = AppUtils.flac2wav(music.musicPath);
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
            baseUrl: music.baseUrl,
            neteaseId: music.neteaseId,
            existFile: checkFileExist(music));
        await DBLogic.to.importMusic(downloadMusic);
      }
    });
  }

  Widget versionView() {
    return SizedBox(
        height: 24.h,
        child: Center(
          child: Text("Ver.$appVersion${env == "prod" ? "" : " Preview"}",
              style:
                  Get.isDarkMode ? TextStyleMs.white_12 : TextStyleMs.black_12),
        ));
  }

  bool checkFileExist(InnerMusic music) {
    return File('${SDUtils.path}${music.baseUrl}${music.musicPath}')
        .existsSync();
  }

  Future<void> requestInstallPackagesPermission() async {
    PermissionStatus status = await Permission.requestInstallPackages.request();

    if (status.isPermanentlyDenied) {
      SmartDialog.show(
          builder: (BuildContext context) => TwoButtonDialog(
              title: "please_give_install_permission_manual".tr,
              isShowMsg: false,
              onConfirmListener: () => openAppSettings()));
    } else if (status.isDenied) {
      // 如果权限被拒绝，你可以显示一个解释界面，然后再次请求权限
      bool isShown =
          await Permission.manageExternalStorage.shouldShowRequestRationale;
      if (isShown) {
        // 显示解释界面
        SmartDialog.show(
            builder: (BuildContext context) => TwoButtonDialog(
                title: "please_give_install_permission".tr,
                isShowMsg: false,
                onConfirmListener: () => requestInstallPackagesPermission()));
      }
    } else if (status.isGranted) {
      // 权限已被授予
      GlobalLogic.to.checkUpdate(manual: true);
    }
  }
}
