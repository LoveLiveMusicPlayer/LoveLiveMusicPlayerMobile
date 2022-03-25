import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/circular_check_box.dart';
import '../logic.dart';

class Song_libraryTop extends StatelessWidget {
  final Function onPlayTap;
  final Function onScreenTap;
  final Function(bool) onSelectAllTap;
  final Function onCancelTap;

  Song_libraryTop({
    Key? key,
    required this.onPlayTap,
    required this.onScreenTap,
    required this.onSelectAllTap,
    required this.onCancelTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainLogic>(builder: (logic) {
      return logic.state.isSelect ? _buildSelectSong() : _buildPlaySong();
    });
    //
  }

  ///播放歌曲条目
  Widget _buildPlaySong() {
    return Container(
      height: 45.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.w,
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
    return GestureDetector(
      onTap: () {
        onPlayTap();
      },
      child: Container(
          width: 56.w,
          height: 24.w,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFF86C9),
                  Color(0xFFF940A7),
                ],
              ),
              borderRadius: BorderRadius.circular(12.w),
              boxShadow: [
                BoxShadow(
                    color: Color(0xffcccccc),
                    spreadRadius: 1,
                    offset: Offset.fromDirection(18.w, -1.w),
                    blurRadius: 1)
              ]),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 20.w,
          )),
    );
  }

  ///歌曲总数
  Widget _buildSongNumText() {
    return Expanded(
      child: GetBuilder<MainLogic>(builder: (logic) {
        return Text(
          "${logic.state.items.length}首歌曲",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 14.w,
              fontWeight: FontWeight.bold),
        );
      }),
    );
  }

  ///筛选按钮
  Widget _buildScreen() {
    return GestureDetector(
      onTap: () {
        onScreenTap();
      },
      child: Padding(
        padding:
            EdgeInsets.only(right: 16.w, top: 5.w, bottom: 5.w, left: 30.w),
        child: Image.asset(
          "assets/main/ic_screen.jpg",
          width: 20.w,
          height: 20.w,
        ),
      ),
    );
  }

  ///播放歌曲条目
  Widget _buildSelectSong() {
    return Container(
      height: 45.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.w,
          ),
          GetBuilder<MainLogic>(builder: (logic) {
            return CircularCheckBox(
              checkd: logic.state.selectAll,
              checkIconColor: const Color(0xFFF940A7),
              uncheckedIconColor: const Color(0xFF999999),
              spacing: 10.w,
              iconSize: 25,
              title: "选择全部/已选${logic.getCheckedSong()}首",
              titleColor: Color(0xFF333333),
              titleSize: 15.sp,
              onCheckd: (value) {
                logic.state.selectAll = value;
                onSelectAllTap(value);
              },
            );
          }),
          Expanded(child: Container()),
          GestureDetector(
            onTap: () {
              onCancelTap();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 16.w),
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
