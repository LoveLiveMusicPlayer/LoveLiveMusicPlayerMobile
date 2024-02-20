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
import 'package:lovelivemusicplayer/global/global_update.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/cloud_data.dart';
import 'package:lovelivemusicplayer/models/cloud_update.dart';
import 'package:lovelivemusicplayer/models/ftp_music.dart';
import 'package:lovelivemusicplayer/models/group.dart';
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

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  final global = Get.find<GlobalLogic>();

  refreshList(GroupKey key) {
    final name = key.getName();
    global.currentGroup.value = name;
    DBLogic.to.findAllListByGroup(name);
  }

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
                fontSize: 17.h,
                color: Get.isDarkMode ? ColorMs.colorEDF5FF : Colors.black)),
        SizedBox(height: 16.h)
      ],
    );
  }

  Widget renderItem(GroupKey groupLeft, GroupKey? groupRight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        showGroupButton(groupLeft.getDrawable(),
            onTap: () => refreshList(groupLeft)),
        Visibility(
          visible: groupRight != null,
          maintainAnimation: true,
          maintainSize: true,
          maintainState: true,
          child: showGroupButton(groupRight!.getDrawable(),
              onTap: () => refreshList(groupRight)),
        )
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
        SizedBox(height: 16.h),
        renderItem(GroupKey.groupYohane, GroupKey.groupCombine),
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
                UpdateLogic.to.checkUpdate();
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

    await loopParseData(
        data.music.us, data.album.us, GroupKey.groupUs.getName());
    await loopParseData(
        data.music.aqours, data.album.aqours, GroupKey.groupAqours.getName());
    await loopParseData(data.music.nijigasaki, data.album.nijigasaki,
        GroupKey.groupNijigasaki.getName());
    await loopParseData(
        data.music.liella, data.album.liella, GroupKey.groupLiella.getName());
    await loopParseData(data.music.combine, data.album.combine,
        GroupKey.groupCombine.getName());
    await loopParseData(data.music.hasunosora, data.album.hasunosora,
        GroupKey.groupHasunosora.getName());
    await loopParseData(
        data.music.yohane, data.album.yohane, GroupKey.groupYohane.getName());
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
}
