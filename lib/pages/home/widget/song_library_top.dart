import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import '../../../widgets/circular_check_box.dart';

class Song_libraryTop extends StatelessWidget {
  final Function onPlayTap;
  final GestureTapCallback onScreenTap;
  final Function(bool) onSelectAllTap;
  final Function onCancelTap;

  Song_libraryTop({
    Key? key,
    required this.onPlayTap,
    required this.onScreenTap,
    required this.onSelectAllTap,
    required this.onCancelTap,
  }) : super(key: key);

  final global = Get.find<GlobalLogic>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (logic) {
      return buildTopWidget();
    });
    //
  }

  ///获取顶部显示布局
  Widget buildTopWidget() {
    if (HomeController.to.state.isSelect) {
      if (HomeController.to.state.currentIndex.value == 2 ||
          HomeController.to.state.currentIndex.value == 4) {
        return Container();
      } else {
        return _buildSelectSong();
      }
    } else {
      if (HomeController.to.state.currentIndex.value == 2 ||
          HomeController.to.state.currentIndex.value == 4) {
        return Container();
      } else {
        return _buildPlaySong();
      }
    }
  }

  ///播放歌曲条目
  Widget _buildPlaySong() {
    return Container(
      height: 45.h,
      color: const Color(0xFFF2F8FF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.h,
          ),
          _buildPlayBtn(),
          SizedBox(
            width: 10.h,
          ),
          _buildSongNumText(),
          _buildScreen(),
        ],
      ),
    );
  }

  ///播放按钮
  Widget _buildPlayBtn() {
    return InkWell(
      onTap: () {
        onPlayTap();
      },
      child: Container(
          width: 56.h,
          height: 24.h,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFF86C9),
                  Color(0xFFF940A7),
                ],
              ),
              borderRadius: BorderRadius.circular(12.h),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xFFD3E0EC),
                    blurRadius: 6,
                    offset: Offset(5, 3)),
              ]),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 20.h,
          )),
    );
  }

  ///歌曲总数
  Widget _buildSongNumText() {
    return Expanded(
      child: Obx(() {
        return Text(
          "${global.getListSize(HomeController.to.state.currentIndex.value, global.databaseInitOver.value)}首歌曲",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 14.h,
              fontWeight: FontWeight.bold),
        );
      }),
    );
  }

  ///筛选按钮
  Widget _buildScreen() {
    return Padding(
      padding: EdgeInsets.only(right: 16.h, top: 5.h, bottom: 5.h, left: 30.h),
      child: touchIconByAsset(
          path: "assets/main/ic_screen.svg",
          onTap: onScreenTap,
          width: 15,
          height: 15),
    );
  }

  ///播放歌曲条目
  Widget _buildSelectSong() {
    return Container(
      color: const Color(0xFFF2F8FF),
      height: 45.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.h,
          ),
          GetBuilder<HomeController>(builder: (logic) {
            return CircularCheckBox(
              checkd: HomeController.to.state.selectAll,
              checkIconColor: const Color(0xFFF940A7),
              uncheckedIconColor: const Color(0xFF999999),
              spacing: 10.h,
              iconSize: 25,
              title: "选择全部/已选${HomeController.to.getCheckedSong()}首",
              titleColor: const Color(0xFF333333),
              titleSize: 15.sp,
              onCheckd: (value) {
                HomeController.to.state.selectAll = value;
                onSelectAllTap(value);
              },
            );
          }),
          Expanded(child: Container()),
          InkWell(
            onTap: () {
              onCancelTap();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.h),
              child: Text(
                "取消",
                style:
                    TextStyle(color: const Color(0xFF333333), fontSize: 15.sp),
              ),
            ),
          )
        ],
      ),
    );
  }
}
