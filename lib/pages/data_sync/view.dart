import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/ftp_cmd.dart';
import 'package:lovelivemusicplayer/models/trans_data.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';
import 'package:lovelivemusicplayer/widgets/water_ripple.dart';
import 'package:lovelivemusicplayer/widgets/websocket_widget.dart';

import 'logic.dart';

class DataSyncPage extends StatefulWidget {
  const DataSyncPage({super.key});

  @override
  State<DataSyncPage> createState() => _DataSyncPageState();
}

class _DataSyncPageState extends WebSocketState<DataSyncPage> {
  final logic = Get.put(DataSyncLogic());
  final state = Get.find<DataSyncLogic>().state;
  final GlobalKey<WaterRippleState> waterRippleKey =
      GlobalKey<WaterRippleState>();

  @override
  String get title => 'data_sync'.tr;

  @override
  List<Widget> body() {
    return [
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
        SvgPicture.asset(Assets.drawerDrawerSecret, width: 15.r, height: 15.r),
        SizedBox(width: 10.r),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.w),
          child: Text('keep_same_lan'.tr, style: TextStyleMs.gray_12),
        )
      ]),
      SizedBox(height: 4.h),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.asset(Assets.drawerDrawerSecret, width: 15.r, height: 15.r),
        SizedBox(width: 10.r),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.w),
          child: Text('keep_screen_and_scan_qr'.tr, style: TextStyleMs.gray_12),
        )
      ]),
      SizedBox(height: 60.h),
      Visibility(
          visible: isConnected,
          child: Column(children: [
            btnFunc(Assets.syncIconPhone, 'phone2pc'.tr, () {
              if (state.isTransferring) {
                SmartDialog.showToast('transferring'.tr);
                return;
              }
              logic.setTransferring(true);
              logic.getPhone2PcData().then((transData) {
                addMsgToChannel(
                    FtpCmd(cmd: "phone2pc", body: transDataToJson(transData)));
              });
            }),
            SizedBox(height: 28.h),
            btnFunc(Assets.syncIconComputer, 'pc2phone'.tr, () {
              if (state.isTransferring) {
                SmartDialog.showToast('transferring'.tr);
                return;
              }
              logic.setTransferring(true);
              logic.getPc2PhoneData().then((transData) {
                addMsgToChannel(
                    FtpCmd(cmd: "pc2phone", body: transDataToJson(transData)));
              });
            }),
            SizedBox(height: 28.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoSwitch(
                    value: state.switchValue,
                    activeColor: const Color.fromARGB(255, 228, 0, 127),
                    onChanged: (value) {
                      if (value) {
                        SmartDialog.show(builder: (context) {
                          return TwoButtonDialog(
                            title: 'warning_choose'.tr,
                            msg: 'confirm_full_trans'.tr,
                            onConfirmListener: () {
                              logic.setSwitchValue(value);
                            },
                          );
                        });
                      } else {
                        logic.setSwitchValue(value);
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
          child: btnFunc(Assets.syncIconScanQr, 'device_pair'.tr, () {
            Get.toNamed(Routes.routeScan)?.then((msg) {
              state.ipAddress = msg as String?;
              if (state.ipAddress != null) {
                openWebsocket(state.ipAddress!, state.port);
              }
            });
          }))
    ];
  }

  @override
  Future<void> onHandleMsg(msg) async {
    final ftpCmd = ftpCmdFromJson(msg);
    switch (ftpCmd.cmd) {
      case "version":
        if ((int.tryParse(ftpCmd.body) ?? 0) != GlobalLogic.to.transVer) {
          SmartDialog.showToast("version_incompatible".tr);
          Get.back();
          return;
        }
        addMsgToChannel(FtpCmd(cmd: "connected", body: ''));
        break;
      case "phone2pc":
        final data = transDataFromJson(ftpCmd.body);
        await logic.replaceLoveList(data);
        release();
        break;
      case "pc2phone":
        final data = transDataFromJson(ftpCmd.body);
        await logic.replaceLoveList(data);
        await logic.replacePcMenuList(data);
        release();
        break;
      case "back":
        setConnect(false);
        channel?.sink.close();
        break;
    }
  }

  @override
  void dispose() {
    Get.delete<DataSyncLogic>();
    super.dispose();
  }
}
