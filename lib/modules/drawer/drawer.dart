import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/widgets/drawer_function_button.dart';
import 'package:web_socket_channel/io.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  bool switchValue = false;
  final global = Get.put(GlobalLogic());

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          topView(),
          groupView(),
          functionView()
        ],
      ),
    ));
  }

  Widget topView() {
    return Column(
      children: [
        SizedBox(height: 12.h),
        logoIcon("ic_head.jpg", width: 96, height: 96, radius: 96),
        SizedBox(height: 12.h),
        Text("LoveLiveMusicPlayer",
            style:
            TextStyle(fontSize: 17.sp, color: const Color(0xFF333333))),
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
            showGroupButton("assets/drawer/logo_lovelive.png", onTap: () {
              global.currentGroup.value = "all";
            }, innerWidth: 107, innerHeight: 27),
            showGroupButton("assets/drawer/logo_us.png", onTap: () {
              global.currentGroup.value = "μ's";
            }, innerWidth: 74, innerHeight: 58),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showGroupButton("assets/drawer/logo_aqours.png", onTap: () {
              global.currentGroup.value = "aqours";
            }, innerWidth: 90, innerHeight: 36),
            showGroupButton("assets/drawer/logo_nijigasaki.png", onTap: () {
              global.currentGroup.value = "niji";
            }, innerWidth: 101, innerHeight: 40)
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showGroupButton("assets/drawer/logo_liella.png", onTap: () {
              global.currentGroup.value = "liella";
            }, innerWidth: 100, innerHeight: 35),
            showGroupButton("assets/drawer/logo_allstars.png", onTap: () {
              global.currentGroup.value = "combine";
            }, innerWidth: 88, innerHeight: 44),
          ],
        ),
        SizedBox(height: 20.h)
      ],
    );
  }

  Widget functionView() {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              width: 268.w,
              height: 204.h,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8.w),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white,
                      offset: Offset(-3.w, -3.h),
                      blurStyle: BlurStyle.inner,
                      blurRadius: 6.w),
                  BoxShadow(
                      color: const Color(0xFFD3E0EC),
                      offset: Offset(5.w, 3.h),
                      blurRadius: 6.w),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DrawerFunctionButton(
                      icon: "assets/drawer/drawer_quick_trans.svg",
                      text: "歌曲快传",
                      onTap: () async {
                        var data = await Get.toNamed(Routes.routeScan);
                        if (data != null) {
                          Get.toNamed(Routes.routeTransform,
                              arguments: IOWebSocketChannel.connect(Uri.parse(data)));
                        }
                      },
                    ),
                    DrawerFunctionButton(
                      icon: "assets/drawer/drawer_data_sync.svg",
                      text: "数据同步",
                      onTap: () {

                      },
                    ),
                    DrawerFunctionButton(
                      icon: "assets/drawer/drawer_day_night.svg",
                      text: "夜间模式",
                      hasSwitch: true,
                      callBack: (check) {
                        LogUtil.e(check);
                      }
                    ),
                    DrawerFunctionButton(
                      icon: "assets/drawer/drawer_secret.svg",
                      text: "关于和隐私",
                      onTap: () {

                      },
                    )
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
