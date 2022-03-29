import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import '../../../widgets/circular_check_box.dart';
import '../logic.dart';

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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainLogic>(builder: (logic) {
      return buildTopWidget(logic);
    });
    //
  }

  ///获取顶部显示布局
  Widget buildTopWidget(MainLogic logic){
    if(logic.state.isSelect){
      if(logic.state.currentIndex == 2 || logic.state.currentIndex == 4 ){
        return Container();
      }else{
        return _buildSelectSong();
      }
    }else{
      if(logic.state.currentIndex == 2 || logic.state.currentIndex == 4 ){
        return Container();
      }else{
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
    return GestureDetector(
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
      child: GetBuilder<MainLogic>(builder: (logic) {
        return Text(
          "${logic.state.items.length}首歌曲",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Color(0xFF333333),
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
      child: touchIconByAsset(path: "assets/main/ic_screen.svg", onTap: onScreenTap,
          width: 15, height: 15),
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
          GetBuilder<MainLogic>(builder: (logic) {
            return CircularCheckBox(
              checkd: logic.state.selectAll,
              checkIconColor: const Color(0xFFF940A7),
              uncheckedIconColor: const Color(0xFF999999),
              spacing: 10.h,
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
