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
  final GestureTapCallback onFunctionTap;
  final Function(bool) onSelectAllTap;
  final Function onCancelTap;
  final bool selectAll;
  final bool isSelect;
  final int itemsLength;
  final int checkedItemLength;
  final bool hasBg;
  final Color? bgColor;

  const DetailsListTop({
    super.key,
    this.selectAll = false,
    this.isSelect = false,
    this.itemsLength = 0,
    this.checkedItemLength = 0,
    this.hasBg = false,
    this.bgColor,
    required this.onPlayTap,
    required this.onFunctionTap,
    required this.onSelectAllTap,
    required this.onCancelTap,
  });

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
          SizedBox(width: 16.w),
          _buildPlayBtn(),
          SizedBox(width: 10.w),
          _buildSongNumText(),
          _buildFilter(),
        ],
      ),
    );
  }

  ///播放按钮
  Widget _buildPlayBtn() {
    final hasShadow = GlobalLogic.to.bgPhoto.value == "";
    return GestureDetector(
      onTap: () => onPlayTap(),
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
                  : null),
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
  Widget _buildFilter() {
    final color = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? ColorMs.colorFFFFFF
        : ColorMs.colorCCCCCC;
    return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: neumorphicButton(
          Assets.mainIcFunction,
          onFunctionTap,
          width: 30,
          height: 30,
          iconColor: color,
          hasShadow: false,
          padding: EdgeInsets.all(6.w),
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        ));
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
          SizedBox(width: 16.w),
          CircularCheckBox(
            checked: selectAll,
            checkIconColor: ColorMs.colorF940A7,
            uncheckedIconColor: ColorMs.colorD6D6D6,
            spacing: 10.h,
            iconSize: 25,
            title:
                "${'select_items'.tr} $checkedItemLength ${'total_number_unit'.tr}",
            textStyle: textStyle,
            onChecked: onSelectAllTap,
          ),
          Expanded(child: Container()),
          GestureDetector(
            onTap: () => onCancelTap(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 5.h),
              child: Text('finish'.tr, style: textStyle),
            ),
          )
        ],
      ),
    );
  }
}
