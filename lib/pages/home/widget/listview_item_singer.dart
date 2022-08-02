import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

///歌手 item
class ListViewItemSinger extends StatefulWidget {
  Artist artist;

  int index = 0;

  ///当前选中状态
  bool checked;

  ///是否选择条目
  bool isSelect;

  Function(int, bool) onItemTap;

  ListViewItemSinger(
      {Key? key,
      required this.index,
      required this.onItemTap,
      this.checked = false,
      this.isSelect = false,
      required this.artist})
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
        Visibility(
          visible: widget.isSelect,
          child: Padding(
            padding: EdgeInsets.only(right: 10.h),
            child: CircularCheckBox(
                checkd: widget.checked,
                onCheckd: (checked) {
                  widget.checked = checked;
                  widget.onItemTap(widget.index, checked);
                }),
          ),
        ),
        showImg(widget.artist.photo, 48.h, 48.h,
            radius: 24.h, hasShadow: false),
        SizedBox(
          width: 10.h,
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              widget.checked = !widget.checked;
              widget.onItemTap(widget.index, widget.checked);
              setState(() {});
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
                      color: const Color(0xFF333333),
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
