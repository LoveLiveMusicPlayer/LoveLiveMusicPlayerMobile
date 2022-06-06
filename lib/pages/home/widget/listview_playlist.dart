import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';

///歌单
class ListViewItemPlaylist extends StatefulWidget {
  int index;
  String name;
  String artist;
  Function(int) onTap;

  ListViewItemPlaylist(
      {Key? key, required this.index, required this.name, required this.artist, required this.onTap})
      : super(key: key);

  @override
  State<ListViewItemPlaylist> createState() => _ListViewItemPlaylist();
}

class _ListViewItemPlaylist extends State<ListViewItemPlaylist> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F8FF),
      child: Row(
        children: [
          _buildContent(),
        ],
      ),
    );
  }

  ///中间标题部分
  Widget _buildContent() {
    return Container(
      height: 25.h,
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: 200.w
              ),
              child: Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: const Color(0xff333333),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold),
              ),
            )
          ]),
          SizedBox(
            width: 4.w,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: 100.w
                ),
                child: Text(
                  "-${widget.artist}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xff999999),
                    fontSize: 12.sp,
                  ),
                ),
              )
            ],
          ),
          touchIconByAsset(
              path: "assets/dialog/ic_delete.svg",
              onTap: () {
                widget.onTap(widget.index);
              },
              width: 16.h,
              height: 16.h,
              color: const Color(0xFF999999)),
          SizedBox(
            width: 16.w,
          )
        ],
      ),
    );
  }
}
