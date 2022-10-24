import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class DialogSongInfo extends StatefulWidget {
  final Music music;

  const DialogSongInfo({Key? key, required this.music}) : super(key: key);

  @override
  State<DialogSongInfo> createState() => _DialogSongInfoState();
}

class _DialogSongInfoState extends State<DialogSongInfo> {
  String? date;
  String? category;

  @override
  void initState() {
    super.initState();
    DBLogic.to.findAlbumById(widget.music.albumId!).then((value) {
      date = value?.date;
      category = value?.category;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          boxShadow: [
            BoxShadow(
                color: Get.theme.primaryColor, blurRadius: 4, spreadRadius: 4)
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h))),
      height: 320.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.h),
            child: Text("歌曲信息",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.isDarkMode
                    ? TextStyleMs.white_17_bold
                    : TextStyleMs.black_17_bold),
          ),
          Divider(
              height: 0.5.h,
              color:
                  Get.isDarkMode ? ColorMs.color737373 : ColorMs.colorCFCFCF),
          _buildItem("专辑: ", widget.music.albumName, true),
          _buildItem("时长: ", widget.music.time, true),
          _buildItem(
              "位置: ", "${widget.music.baseUrl}${widget.music.musicPath}", true),
          _buildItem("发行日期: ", date, true),
          _buildItem("分类: ", category, false)
        ],
      ),
    );
  }

  ///单个条目
  Widget _buildItem(String title, String? message, bool showLin) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h, right: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 14.h,
          ),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : ColorMs.color666666,
                    fontSize: 15.sp),
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                  child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(message ?? "未知",
                    style: TextStyle(
                        color:
                            Get.isDarkMode ? Colors.white : ColorMs.color666666,
                        fontSize: 15.sp)),
              ))
            ],
          ),
          SizedBox(
            height: 14.h,
          ),
          Visibility(
            visible: showLin,
            child: Divider(
              height: 0.5.h,
              color: Get.isDarkMode ? ColorMs.color737373 : ColorMs.colorCFCFCF,
            ),
          )
        ],
      ),
    );
  }
}
