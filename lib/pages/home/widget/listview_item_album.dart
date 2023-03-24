import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
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

class _ListViewItemAlbumState extends State<ListViewItemAlbum> {
  @override
  Widget build(BuildContext context) {
    final borderWidth = (ScreenUtil().screenWidth - 72.w) / 3;
    return InkWell(
        onTap: clickItem,
        child: Column(children: [
          SizedBox(
            height: borderWidth,
            width: borderWidth,
            child: Hero(
                tag: "album${widget.album.albumId}",
                child: showImg(
                    SDUtils.getImgPath(fileName: widget.album.coverPath!),
                    borderWidth,
                    borderWidth,
                    hasShadow: false,
                    onTap: clickItem)),
          ),
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
                      uncheckedIconColor: ColorMs.colorD6D6D6,
                      checkIconColor: ColorMs.colorF940A7,
                      onCheckd: (checked) {
                        widget.checked = checked;
                        widget.onItemTap(widget.album, checked);
                      }),
                ),
              ),
              Expanded(
                  child: Text(widget.album.albumName!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: (Get.isDarkMode ||
                              GlobalLogic.to.bgPhoto.value != "")
                          ? TextStyleMs.f12_400
                              .copyWith(color: ColorMs.colorFFFFFF)
                          : TextStyleMs.f12_400.copyWith(color: Colors.black)))
            ],
          )
        ]));
  }

  clickItem() {
    widget.checked = !widget.checked;
    widget.onItemTap(widget.album, widget.checked);
    setState(() {});
  }
}
