import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/ftp_cmd.dart';
import 'package:lovelivemusicplayer/models/love.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/trans_data.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';
import 'package:lovelivemusicplayer/widgets/water_ripple.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/io.dart';

class DataSync extends StatefulWidget {
  const DataSync({super.key});

  @override
  State<DataSync> createState() => _DataSyncState();
}

class _DataSyncState extends State<DataSync> {
  final GlobalKey<WaterRippleState> waterRippleKey =
      GlobalKey<WaterRippleState>();
  IOWebSocketChannel? channel;

  var isConnected = false;
  bool switchValue = false;
  bool isTransferring = false;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    AppUtils.uploadEvent("DataSync");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: isConnected
            ? () async {
                showBackDialog();
                return false;
              }
            : null,
        child: body());
  }

  Widget body() {
    return Scaffold(
      body: Column(
        children: [
          DetailsHeader(
              title: 'data_sync'.tr,
              onBack: () {
                if (isConnected) {
                  showBackDialog();
                } else {
                  Get.back();
                }
              }),
          SizedBox(height: 15.h),
          Stack(
            children: [
              Visibility(
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  visible: !isConnected,
                  child: Center(
                      child: SvgPicture.asset(Assets.syncIconDataSync,
                          width: 300.r, height: 300.r))),
              Visibility(
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  visible: isConnected,
                  child: Center(child: WaterRipple(key: waterRippleKey)))
            ],
          ),
          SizedBox(height: 20.h),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset(Assets.drawerDrawerSecret,
                width: 15.r, height: 15.r),
            SizedBox(width: 10.r),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text('keep_same_lan'.tr, style: TextStyleMs.gray_12),
            )
          ]),
          SizedBox(height: 4.h),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset(Assets.drawerDrawerSecret,
                width: 15.r, height: 15.r),
            SizedBox(width: 10.r),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text('keep_screen_and_scan_qr'.tr,
                  style: TextStyleMs.gray_12),
            )
          ]),
          SizedBox(height: 60.h),
          Visibility(
              visible: isConnected,
              child: Column(children: [
                btnFunc(Assets.syncIconPhone, 'phone2pc'.tr, () async {
                  if (isTransferring) {
                    SmartDialog.showToast('transferring'.tr);
                    return;
                  }
                  isTransferring = true;
                  await sendPhone2pc();
                }),
                SizedBox(height: 28.h),
                btnFunc(Assets.syncIconComputer, 'pc2phone'.tr, () async {
                  if (isTransferring) {
                    SmartDialog.showToast('transferring'.tr);
                    return;
                  }
                  isTransferring = true;
                  await sendPc2phone();
                }),
                SizedBox(height: 28.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoSwitch(
                        value: switchValue,
                        activeColor: const Color.fromARGB(255, 228, 0, 127),
                        onChanged: (value) {
                          if (value) {
                            SmartDialog.show(builder: (context) {
                              return TwoButtonDialog(
                                title: 'warning_choose'.tr,
                                msg: 'confirm_full_trans'.tr,
                                onConfirmListener: () {
                                  switchValue = value;
                                  setState(() {});
                                },
                              );
                            });
                          } else {
                            switchValue = value;
                            setState(() {});
                          }
                        }),
                    SizedBox(width: 10.w),
                    Text('cover_full_data'.tr,
                        style: Get.isDarkMode
                            ? TextStyleMs.pink_15
                            : TextStyleMs.black_15)
                  ],
                )
              ])),
          Visibility(
              visible: !isConnected,
              child: btnFunc(Assets.syncIconScanQr, 'device_pair'.tr, () async {
                final ip = await Get.toNamed(Routes.routeScan);
                if (ip != null) {
                  openWS(ip);
                }
              })),
        ],
      ),
    );
  }

  Widget btnFunc(String asset, String title, GestureTapCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 220.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? ColorMs.color1E2328
                  : ColorMs.colorLightPrimary,
              borderRadius: BorderRadius.circular(6.h),
              boxShadow: [
                BoxShadow(
                    color: Get.isDarkMode
                        ? ColorMs.color1E2328
                        : ColorMs.colorD3E0EC,
                    offset: const Offset(5, 3),
                    blurRadius: 6),
              ],
            ),
            child: Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset(asset,
                  colorFilter:
                      ColorFilter.mode(ColorMs.colorF940A7, BlendMode.srcIn),
                  width: 13.h,
                  height: 20.h),
              SizedBox(width: 11.r),
              Text(title, style: TextStyleMs.pink_15)
            ]))));
  }

  showBackDialog() {
    final width = min(0.4 * Get.height, 0.8 * Get.width);
    SmartDialog.show(builder: (context) {
      return Container(
        width: width,
        height: 150.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: EdgeInsets.only(bottom: 30.h),
            child: Text('terminate_trans'.tr,
                style: TextStyleMs.black_14, textAlign: TextAlign.center),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = ftpCmdToJson(FtpCmd(cmd: "stop", body: ""));
              channel?.sink.add(message);
              SmartDialog.dismiss();
              DBLogic.to
                  .findAllListByGroup(GlobalLogic.to.currentGroup.value)
                  .then((value) => Get.back());
            },
            child: Padding(
              padding: EdgeInsets.all(8.h),
              child: Text('confirm'.tr, style: TextStyleMs.white_14),
            ),
          )
        ]),
      );
    });
  }

  sendPhone2pc() async {
    // 传输我喜欢列表 + 手机歌单列表
    final body = transDataToJson(await DBLogic.to
        .getTransPhoneData(needMenuList: true, isCover: switchValue));
    final cmd = FtpCmd(cmd: "phone2pc", body: body);
    channel?.sink.add(ftpCmdToJson(cmd));
  }

  sendPc2phone() async {
    // 传输我喜欢列表
    final body = transDataToJson(
        await DBLogic.to.getTransPhoneData(isCover: switchValue));
    final cmd = FtpCmd(cmd: "pc2phone", body: body);
    channel?.sink.add(ftpCmdToJson(cmd));
  }

  openWS(String ip) {
    channel = IOWebSocketChannel.connect(Uri.parse("ws://$ip:4389"));
    channel!.stream.listen((msg) async {
      final ftpCmd = ftpCmdFromJson(msg as String);
      switch (ftpCmd.cmd) {
        case "version":
          if ((int.tryParse(ftpCmd.body) ?? 0) != transVer) {
            SmartDialog.showToast("version_incompatible".tr);
            Get.back();
            return;
          }
          final cmd = FtpCmd(cmd: "connected", body: '');
          channel?.sink.add(ftpCmdToJson(cmd));
          break;
        case "phone2pc":
          final data = transDataFromJson(ftpCmd.body);
          await replaceLoveList(data);
          release();
          break;
        case "pc2phone":
          final data = transDataFromJson(ftpCmd.body);
          await replaceLoveList(data);
          await replacePcMenuList(data);
          release();
          break;
        case "back":
          isConnected = false;
          setState(() {});
          channel?.sink.close();
          break;
      }
    }, onError: (e) {
      SmartDialog.showToast('connect_fail'.tr);
      Log4f.i(msg: e.toString());
    }, cancelOnError: true);
    isConnected = true;
    setState(() {});
    final message =
        ftpCmdToJson(FtpCmd(cmd: "version", body: transVer.toString()));
    channel?.sink.add(message);
  }

  replaceLoveList(TransData data) async {
    await DBLogic.to.loveDao.deleteAllLoves();
    await Future.forEach<Love>(data.love, (love) async {
      await DBLogic.to.loveDao.insertLove(love);
    });
  }

  replacePcMenuList(TransData data) async {
    final menuList = data.menu;
    if (data.isCover) {
      await DBLogic.to.menuDao.deleteAllMenus();
    } else {
      await DBLogic.to.menuDao.deletePcMenu();
    }
    await Future.forEach<TransMenu>(menuList, (menu) async {
      final musicList = <String>[];
      await Future.forEach<String>(menu.musicList, (musicUId) async {
        final music = await DBLogic.to.musicDao.findMusicByUId(musicUId);
        if (music != null) {
          musicList.add(musicUId);
        }
      });
      if (musicList.isNotEmpty) {
        await DBLogic.to.menuDao.insertMenu(Menu(
            id: menu.menuId,
            date: menu.date,
            name: menu.name,
            music: musicList));
      }
    });
  }

  release() {
    final message = ftpCmdToJson(FtpCmd(cmd: "finish", body: ""));
    channel?.sink.add(message);
    SmartDialog.dismiss();
    DBLogic.to
        .findAllListByGroup(GlobalLogic.to.currentGroup.value)
        .then((value) => Get.back());
  }

  @override
  void dispose() {
    Wakelock.disable();
    channel?.sink.close();
    super.dispose();
  }
}
