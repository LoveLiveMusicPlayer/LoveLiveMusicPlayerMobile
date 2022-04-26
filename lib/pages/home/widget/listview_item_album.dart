import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';
import '../../../utils/sd_utils.dart';

///专辑 item
class ListViewItemAlbum extends StatefulWidget {
  Album album;

  ///当前选中状态
  bool checked;

  ///是否选择条目
  bool isSelect;
  Function(Album, bool) onItemTap;

  ListViewItemAlbum(
      {Key? key,
      required this.album,
      required this.onItemTap,
      this.checked = false,
      this.isSelect = false})
      : super(key: key);

  @override
  State<ListViewItemAlbum> createState() => _ListViewItemAlbumState();
}

class _ListViewItemAlbumState extends State<ListViewItemAlbum> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          widget.checked = !widget.checked;
          widget.onItemTap(widget.album, widget.checked);
          setState(() {});
        },
        child: Column(children: [
          showImg(
              SDUtils.getImgPath(
                  widget.album.coverPath?.first ?? "ic_head.jpg"),
              width: 95.h,
              height: 95.h,
              fit: BoxFit.cover,
              hasShadow: false),
          Container(
            height: 40.h,
            alignment: Alignment.center,
            child: Text(
              widget.album.name ?? "",
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.bold),
            ),
          )
        ]));
  }
}
