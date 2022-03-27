import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:web_socket_channel/io.dart';
import 'package:get/get.dart';

import '../../routes.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: const Color(0xFFF2F8FF),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 12.h),
              logoIcon("ic_head.jpg", width: 96, height: 96, radius: 96),
              SizedBox(height: 12.h),
              Text("LoveLiveMusicPlayer",
                  style: TextStyle(fontSize: 17.sp, color: const Color(0xFF333333))),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  showGroupButton("assets/drawer/logo_lovelive.png", innerWidth: 107, innerHeight: 27),
                  showGroupButton("assets/drawer/logo_us.png", innerWidth: 74, innerHeight: 58),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkResponse(
                    highlightColor: Colors.transparent,
                    radius: 0.0,
                    onTap: () async {
                      var data = await Get.toNamed(Routes.routeScan);
                      if (data != null) {
                        Get.toNamed(Routes.routeTransform, arguments: IOWebSocketChannel.connect(Uri.parse(data)));
                      }
                    },
                    child: showGroupButton("assets/drawer/logo_aqours.png", innerWidth: 90, innerHeight: 36)
                  ),
                  showGroupButton("assets/drawer/logo_nijigasaki.png", innerWidth: 101, innerHeight: 40)
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  showGroupButton("assets/drawer/logo_liella.png", innerWidth: 100, innerHeight: 35),
                  showGroupButton("assets/drawer/logo_allstars.png", innerWidth: 88, innerHeight: 44),
                ],
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Container(
                  width: 268.w,
                  height: 204.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F8FF),
                    borderRadius: BorderRadius.circular(8.w),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white,
                          offset: Offset(-3.w, -3.h),
                          blurStyle: BlurStyle.inner,
                          blurRadius: 6.w),
                      BoxShadow(color: const Color(0xFFD3E0EC), offset: Offset(5.w, 3.h), blurRadius: 6.w),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: Icon(Icons.music_note, color: const Color(0xFF666666), size: 20.w),
                            ),
                            SizedBox(width: 8.w),
                            Text("歌曲快传", style: TextStyle(color: const Color(0xFF333333), fontSize: 15.sp))
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: Icon(Icons.directions_transit, color: const Color(0xFF666666), size: 20.w),
                            ),
                            SizedBox(width: 8.w),
                            Text("数据同步", style: TextStyle(color: const Color(0xFF333333), fontSize: 15.sp))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  child: Icon(Icons.nights_stay_outlined, color: const Color(0xFF666666), size: 20.w),
                                ),
                                SizedBox(width: 8.w),
                                Text("夜间模式", style: TextStyle(color: const Color(0xFF333333), fontSize: 15.sp))
                              ],
                            ),
                            CupertinoSwitch(value: switchValue, onChanged:(value) {
                              switchValue = value;
                              setState(() {});
                            })
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: Icon(Icons.info_outline, color: const Color(0xFF666666), size: 20.w),
                            ),
                            SizedBox(width: 8.w),
                            Text("关于和隐私", style: TextStyle(color: const Color(0xFF333333), fontSize: 15.sp))
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              )
            ],
          ),
        ));
  }
}
