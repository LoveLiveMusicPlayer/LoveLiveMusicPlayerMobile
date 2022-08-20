import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';

///歌手 item
class ListViewItemSinger extends StatefulWidget {
  Artist artist;

  Function(Artist) onItemTap;

  ListViewItemSinger({Key? key, required this.artist, required this.onItemTap})
      : super(key: key);

  @override
  State<ListViewItemSinger> createState() => _ListViewItemSingerState();
}

class _ListViewItemSingerState extends State<ListViewItemSinger>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      children: [
        showImg(widget.artist.photo, 48.h, 48.h,
            radius: 24.h,
            hasShadow: false,
            onTap: () => widget.onItemTap(widget.artist)),
        SizedBox(
          width: 10.w,
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              widget.onItemTap(widget.artist);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15.sp,
                      color: Get.isDarkMode
                          ? Colors.white
                          : const Color(0xFF333333),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  "${widget.artist.count}首歌",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 10.h,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
