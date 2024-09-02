import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/ftp_cmd.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/header.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:web_socket_channel/io.dart';

abstract class WebSocketState<T extends StatefulWidget> extends State<T> {
  IOWebSocketChannel? channel;

  late String title;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    AppUtils.uploadEvent(runtimeType.toString());
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
        child: Scaffold(
          body: Column(children: [
            AppHeader(
                title: title,
                onBack: () {
                  if (isConnected) {
                    showBackDialog();
                  } else {
                    Get.back();
                  }
                }),
            ...body()
          ]),
        ));
  }

  List<Widget> body();

  void setConnect(bool isConnected) {
    if (mounted) {
      setState(() {
        this.isConnected = isConnected;
      });
    }
  }

  Future<void> onHandleMsg(String msg);

  void openWebsocket(String ipAddress, String port) {
    channel = IOWebSocketChannel.connect(Uri.parse("ws://$ipAddress:$port"));
    channel!.stream.listen((msg) => onHandleMsg(msg as String), onDone: () {
      print("stream is done");
    }, onError: (e) {
      setConnect(false);
      SmartDialog.showToast('connect_fail'.tr);
      Log4f.w(msg: e.toString());
    }, cancelOnError: true);
    setConnect(true);
    addMsgToChannel(
        FtpCmd(cmd: "version", body: GlobalLogic.to.transVer.toString()));
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

  void addMsgToChannel(FtpCmd ftpCmd) {
    if (isConnected) {
      channel?.sink.add(ftpCmdToJson(ftpCmd));
    }
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
            onPressed: () => release(),
            child: Padding(
              padding: EdgeInsets.all(8.h),
              child: Text('confirm'.tr, style: TextStyleMs.white_14),
            ),
          )
        ]),
      );
    });
  }

  void release() {
    addMsgToChannel(FtpCmd(cmd: "finish", body: ""));
    releaseAppend.call();
    SmartDialog.dismiss();
    DBLogic.to
        .findAllListByGroup(GlobalLogic.to.currentGroup.value)
        .then((value) => Get.back());
  }

  void releaseAppend() {}

  @override
  void dispose() {
    WakelockPlus.disable();
    channel?.sink.close();
    super.dispose();
  }
}
