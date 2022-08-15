import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/water_ripple.dart';

class DataSync extends StatefulWidget {
  const DataSync({Key? key}) : super(key: key);

  @override
  State<DataSync> createState() => _DataSyncState();
}

class _DataSyncState extends State<DataSync> {
  final GlobalKey<WaterRippleState> waterRippleKey =
      GlobalKey<WaterRippleState>();

  var isTransferring = false;
  var isConnected = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: body(),
        onWillPop: () async {
          showBackDialog();
          return false;
        });
  }

  Widget body() {
    return Scaffold(
      body: Column(
        children: [
          DetailsHeader(title: '数据同步', onBack: () => showBackDialog()),
          SizedBox(height: 15.h),
          Stack(
            children: [
              Visibility(
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  visible: !isTransferring,
                  child: Center(
                      child: SvgPicture.asset(Assets.syncIconDataSync,
                          width: 300.w, height: 300.w))),
              Visibility(
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  visible: isTransferring,
                  child: Center(child: WaterRipple(key: waterRippleKey)))
            ],
          ),
          SizedBox(height: 20.h),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset(Assets.drawerDrawerSecret,
                width: 15.w, height: 15.w),
            SizedBox(width: 2.w),
            Text("请保持手机和电脑处于同一局域网内", style: TextStyleMs.gray_12)
          ]),
          SizedBox(height: 90.h),
          Visibility(
              visible: isConnected,
              child: Column(children: [
                btnFunc(Assets.syncIconPhone, "手机 ≫ 电脑", () {
                  isTransferring = true;
                  setState(() {});
                }),
                SizedBox(height: 28.h),
                btnFunc(Assets.syncIconComputer, "电脑 ≫ 手机", () {
                  isTransferring = false;
                  setState(() {});
                })
              ])),
          Visibility(
              visible: !isConnected,
              child: btnFunc(Assets.syncIconScanQr, "设备配对", () {
                isConnected = true;
                setState(() {});
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
                  ? const Color(0xFF1E2328)
                  : const Color(0xFFF2F8FF),
              borderRadius: BorderRadius.circular(6.h),
              boxShadow: [
                BoxShadow(
                    color: Get.isDarkMode
                        ? const Color(0xFF1E2328)
                        : const Color(0xFFD3E0EC),
                    offset: const Offset(5, 3),
                    blurRadius: 6),
              ],
            ),
            child: Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset(asset,
                  color: const Color(0xFFF940A7), width: 13.h, height: 20.h),
              SizedBox(width: 11.w),
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
            SmartDialog.dismiss();
            Get.back();
          },
          child: const Text('确定'),
        )
      ]),
    ));
  }
}
