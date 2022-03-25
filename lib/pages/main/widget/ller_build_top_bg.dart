import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/pages/main/state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LlerBuildTopBg extends StatelessWidget {
  MainState data;
  Function(bool) onTabTap;

  LlerBuildTopBg({
    Key? key,
    required this.data,
    required this.onTabTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildBg(children: [
      ///顶部导航+头像
      _buildTab(),
    ]);
  }

  Widget _buildBg({required List<Widget> children}) {
    return Column(
      children: children,
    );
  }

  ///顶部导航+头像
  Widget _buildTab() {
    return SafeArea(
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
          ),
          _buildTabItem("歌词", data.isSelectSongLibrary),
          SizedBox(
            width: 8.w,
          ),
          _buildTabItem("我的", !data.isSelectSongLibrary),
          Expanded(child: Container())
        ],
      ),
    );
  }

  ///单个导航
  Widget _buildTabItem(String title, bool select) {
    return GestureDetector(
      onTap: () {
        onTabTap(select);
      },
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  color: Color(select ? 0xFFF940A7 : 0xFFA9B9CD),
                  fontSize: select ? 24.sp : 16.sp,
                  fontWeight: FontWeight.w900)),
          SizedBox(
            height: 5.w,
          ),
          Visibility(
            visible: select,
            child: Container(
              width: 12.w,
              height: 4.h,
              decoration: BoxDecoration(
                  color: const Color(0xFFF940A7),
                  borderRadius: BorderRadius.circular(2.w)),
            ),
          )
        ],
      ),
    );
  }

  ///头像
  Widget _buildTopHead() {
    return Container(
      child: ClipOval(
        child: Image.asset(""),
      ),
    );
  }
}
