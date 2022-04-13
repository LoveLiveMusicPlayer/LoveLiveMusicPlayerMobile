import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/main/logic.dart';
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
  final global = Get.find<GlobalLogic>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.checked = !widget.checked;
        widget.onItemTap(widget.album, widget.checked);
        setState(() {});
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showImg(
              SDUtils.getImgPath(
                  widget.album.coverPath?.first ?? "ic_head.jpg"),
              width: double.infinity,
              fit: BoxFit.cover,
              hasShadow: false),
          SizedBox(height: 5.w),
          Row(
            children: [
              Expanded(
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
              ),
              Visibility(
                visible: widget.isSelect,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.h),
                  child: CircularCheckBox(
                      checkd: widget.checked,
                      uncheckedIconColor: const Color(0xff999999),
                      checkIconColor: const Color(0xFFF940A7),
                      onCheckd: (checked) {
                        widget.checked = checked;
                        widget.onItemTap(widget.album, checked);
                      }),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
