import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

class SongLibraryTop extends GetView<GlobalLogic> {
  final Function onPlayTap;
  final GestureTapCallback onScreenTap;
  final Function(bool) onSelectAllTap;
  final Function onCancelTap;

  const SongLibraryTop({
    Key? key,
    required this.onPlayTap,
    required this.onScreenTap,
    required this.onSelectAllTap,
    required this.onCancelTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return buildTopWidget();
    });
  }

  ///获取顶部显示布局
  Widget buildTopWidget() {
    if (HomeController.to.state.isSelect.value) {
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
      padding: EdgeInsets.only(bottom: 10.h),
      height: 35.h,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 14.w,
          ),
          _buildPlayBtn(),
          SizedBox(
            width: 10.w,
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
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  ColorMs.colorFF86C9,
                  ColorMs.colorF940A7,
                ],
              ),
              borderRadius: BorderRadius.circular(12.h),
              boxShadow: [
                BoxShadow(
                    color: GlobalLogic.to.getThemeColor(
                        ColorMs.color05080C, ColorMs.colorD3E0EC),
                    blurRadius: 6,
                    offset: const Offset(5, 3)),
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
    final index = HomeController.to.state.currentIndex.value;
    return Expanded(
      child: Obx(() {
        return Text(
            "${controller.getListSize(index, controller.databaseInitOver.value)} ${index == 1 ? 'total_album_number_unit'.tr : 'total_number_unit'.tr}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                Get.isDarkMode ? TextStyleMs.white_14 : TextStyleMs.black_14);
      }),
    );
  }

  ///筛选按钮
  Widget _buildScreen() {
    if (HomeController.to.state.currentIndex.value == 1) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.only(right: 22.w, top: 3.h, bottom: 3.h),
      child: touchIconByAsset(
          path: Assets.mainIcScreen,
          onTap: onScreenTap,
          width: 20,
          height: 20,
          color: ColorMs.colorCCCCCC),
    );
  }

  ///播放歌曲条目
  Widget _buildSelectSong() {
    return Container(
      color: Get.theme.primaryColor,
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
              checkIconColor: ColorMs.colorF940A7,
              uncheckedIconColor: ColorMs.color999999,
              spacing: 10.h,
              iconSize: 25,
              title: "${'select_items'.tr} ${HomeController.to.getCheckedSong()} ${'total_number_unit'.tr}",
              textStyle:
                  Get.isDarkMode ? TextStyleMs.white_15 : TextStyleMs.black_15,
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
                'cancel'.tr,
                style: Get.isDarkMode
                    ? TextStyleMs.white_15
                    : TextStyleMs.black_15,
              ),
            ),
          )
        ],
      ),
    );
  }
}
