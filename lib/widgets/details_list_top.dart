import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

import 'circular_check_box.dart';

class DetailsListTop extends StatelessWidget {
  final Function onPlayTap;
  final GestureTapCallback onScreenTap;
  final Function(bool) onSelectAllTap;
  final Function onCancelTap;
  bool selectAll;
  bool isSelect;
  int itemsLength;
  int checkedItemLength;
  bool hasBg;
  Color? bgColor;

  DetailsListTop({
    Key? key,
    this.selectAll = false,
    this.isSelect = false,
    this.itemsLength = 0,
    this.checkedItemLength = 0,
    this.hasBg = false,
    this.bgColor,
    required this.onPlayTap,
    required this.onScreenTap,
    required this.onSelectAllTap,
    required this.onCancelTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isSelect ? _buildSelectSong() : _buildPlaySong();
  }

  ///播放歌曲条目
  Widget _buildPlaySong() {
    final color = hasBg ? (bgColor ?? Colors.transparent) : Colors.transparent;
    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
            color: color, strokeAlign: BorderSide.strokeAlignOutside),
      ),
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
    final hasShadow = GlobalLogic.to.bgPhoto.value == "";
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
              boxShadow: hasShadow
                  ? [
                      BoxShadow(
                          color: GlobalLogic.to.getThemeColor(
                              ColorMs.color05080C, ColorMs.colorD3E0EC),
                          blurRadius: 6,
                          offset: const Offset(5, 3)),
                    ]
                  : []),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 20.h,
          )),
    );
  }

  ///歌曲总数
  Widget _buildSongNumText() {
    final color = TextStyleMs.f14_400.copyWith(
        color: (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
            ? ColorMs.colorFFFFFF
            : ColorMs.color333333);
    return Expanded(
      child: Text("$itemsLength ${'total_number_unit'.tr}",
          maxLines: 1, overflow: TextOverflow.ellipsis, style: color),
    );
  }

  ///筛选按钮
  Widget _buildScreen() {
    final color = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? ColorMs.colorFFFFFF
        : ColorMs.colorCCCCCC;
    return Padding(
        padding:
            EdgeInsets.only(right: 16.h, top: 5.h, bottom: 5.h, left: 30.h),
        child: touchIconByAsset(
            path: Assets.mainIcScreen,
            onTap: onScreenTap,
            width: 20,
            height: 20,
            color: color));
  }

  ///播放歌曲条目
  Widget _buildSelectSong() {
    final textStyle = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? TextStyleMs.f15_400.copyWith(color: Colors.white)
        : TextStyleMs.f15_400.copyWith(color: Colors.black);
    return Container(
      color: hasBg ? bgColor : Colors.transparent,
      height: 45.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.h,
          ),
          CircularCheckBox(
            checkd: selectAll,
            checkIconColor: ColorMs.colorF940A7,
            uncheckedIconColor: ColorMs.colorD6D6D6,
            spacing: 10.h,
            iconSize: 25,
            title:
                "${'select_items'.tr} $checkedItemLength ${'total_number_unit'.tr}",
            textStyle: textStyle,
            onCheckd: (value) {
              onSelectAllTap(value);
            },
          ),
          Expanded(child: Container()),
          InkWell(
            onTap: () {
              onCancelTap();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.h),
              child: Text('cancel'.tr, style: textStyle),
            ),
          )
        ],
      ),
    );
  }
}
