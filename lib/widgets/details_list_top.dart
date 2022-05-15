import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
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

  DetailsListTop({
    Key? key,
    this.selectAll = false,
    this.isSelect = false,
    this.itemsLength = 0,
    this.checkedItemLength = 0,
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
    return Container(
      height: 45.h,
      color: Get.theme.primaryColor,
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
      child: Text("$itemsLength首歌曲",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.isDarkMode
              ? TextStyleMs.whiteBold_14
              : TextStyleMs.blackBold_14),
    );
  }

  ///筛选按钮
  Widget _buildScreen() {
    return Padding(
      padding: EdgeInsets.only(right: 16.h, top: 5.h, bottom: 5.h, left: 30.h),
      child: touchIconByAsset(
          path: "assets/main/ic_screen.svg",
          onTap: onScreenTap,
          width: 18,
          height: 18),
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
          CircularCheckBox(
            checkd: selectAll,
            checkIconColor: const Color(0xFFF940A7),
            uncheckedIconColor: const Color(0xFF999999),
            spacing: 10.h,
            iconSize: 25,
            title: "选择全部/已选$checkedItemLength首",
            textStyle:
                Get.isDarkMode ? TextStyleMs.white_15 : TextStyleMs.black_15,
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
              child: Text(
                "取消",
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
