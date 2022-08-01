import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
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

class _ListViewItemAlbumState extends State<ListViewItemAlbum>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final borderWidth = (ScreenUtil().screenWidth - 72.w) / 3;
    return InkWell(
        onTap: () {
          widget.checked = !widget.checked;
          widget.onItemTap(widget.album, widget.checked);
          setState(() {});
        },
        child: Column(children: [
          showImg(SDUtils.getImgPath(widget.album.coverPath!), borderWidth,
              borderWidth,
              hasShadow: false),
          SizedBox(
            height: 5.h,
          ),
          Row(
            children: [
              Visibility(
                visible: widget.isSelect,
                child: Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: CircularCheckBox(
                      checkd: widget.checked,
                      uncheckedIconColor: const Color(0xff999999),
                      checkIconColor: const Color(0xFFF940A7),
                      onCheckd: (checked) {
                        widget.checked = checked;
                        widget.onItemTap(widget.album, checked);
                      }),
                ),
              ),
              Expanded(
                  child: Text(
                widget.album.albumName!,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Get.isDarkMode
                    ? TextStyleMs.white_12
                    : TextStyleMs.black_12,
              ))
            ],
          )
        ]));
  }

  @override
  bool get wantKeepAlive => true;
}
