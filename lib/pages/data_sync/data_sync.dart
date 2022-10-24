import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/FtpCmd.dart';
import 'package:lovelivemusicplayer/models/Love.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/models/TransData.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/water_ripple.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/io.dart';

class DataSync extends StatefulWidget {
  const DataSync({Key? key}) : super(key: key);

  @override
  State<DataSync> createState() => _DataSyncState();
}

class _DataSyncState extends State<DataSync> {
  final GlobalKey<WaterRippleState> waterRippleKey =
      GlobalKey<WaterRippleState>();
  IOWebSocketChannel? channel;

  var isConnected = false;

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
              title: '数据同步',
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
            SizedBox(width: 2.r),
            Text("请保持手机和电脑处于同一局域网内", style: TextStyleMs.gray_12)
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 15.r),
            Text("保持屏幕常亮，并扫描PC端二维码", style: TextStyleMs.gray_12)
          ]),
          SizedBox(height: 90.h),
          Visibility(
              visible: isConnected,
              child: Column(children: [
                btnFunc(Assets.syncIconPhone, "手机 ≫ 电脑", () async {
                  await sendPhone2pc();
                }),
                SizedBox(height: 28.h),
                btnFunc(Assets.syncIconComputer, "电脑 ≫ 手机", () async {
                  await sendPc2phone();
                })
              ])),
          Visibility(
              visible: !isConnected,
              child: btnFunc(Assets.syncIconScanQr, "设备配对", () async {
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
    return InkWell(
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
                  color: ColorMs.colorF940A7, width: 13.h, height: 20.h),
              SizedBox(width: 11.r),
              Text(title, style: TextStyleMs.pink_15)
            ]))));
  }

  showBackDialog() {
    SmartDialog.compatible.show(
        widget: Container(
      width: 300.w,
      height: 150.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 250.w,
          margin: EdgeInsets.only(bottom: 30.h),
          child: Text("退出后会中断连接及传输，是否继续？", style: TextStyleMs.black_14),
        ),
        ElevatedButton(
          onPressed: () async {
            final message = ftpCmdToJson(FtpCmd(cmd: "stop", body: ""));
            channel?.sink.add(message);
            SmartDialog.compatible.dismiss();
            DBLogic.to
                .findAllListByGroup(GlobalLogic.to.currentGroup.value)
                .then((value) => Get.back());
          },
          child: const Text('确定'),
        )
      ]),
    ));
  }

  sendPhone2pc() async {
    // 传输我喜欢列表 + 手机歌单列表
    final body =
        transDataToJson(await DBLogic.to.getTransPhoneData(needMenuList: true));
    final cmd = FtpCmd(cmd: "phone2pc", body: body);
    channel?.sink.add(ftpCmdToJson(cmd));
  }

  sendPc2phone() async {
    // 传输我喜欢列表
    final body = transDataToJson(await DBLogic.to.getTransPhoneData());
    final cmd = FtpCmd(cmd: "pc2phone", body: body);
    channel?.sink.add(ftpCmdToJson(cmd));
  }

  openWS(String ip) {
    channel = IOWebSocketChannel.connect(Uri.parse("ws://$ip:4389"));
    channel!.stream.listen((msg) async {
      final ftpCmd = ftpCmdFromJson(msg as String);
      switch (ftpCmd.cmd) {
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
      Log4f.w(msg: "连接失败");
      Log4f.e(msg: e.toString(), writeFile: true);
    }, cancelOnError: true);
    isConnected = true;
    setState(() {});
    final cmd = FtpCmd(cmd: "connected", body: '');
    channel?.sink.add(ftpCmdToJson(cmd));
  }

  replaceLoveList(TransData data) async {
    await DBLogic.to.loveDao.deleteAllLoves();
    await Future.forEach<Love>(data.love, (love) async {
      await DBLogic.to.loveDao.insertLove(love);
    });
  }

  replacePcMenuList(TransData data) async {
    final menuList = data.menu;
    await DBLogic.to.menuDao.deletePcMenu();
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
