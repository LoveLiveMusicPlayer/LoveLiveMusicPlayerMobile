import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/main/logic.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

import '../../../utils/sd_utils.dart';

///专辑 item
class ListViewItemAlbum extends StatefulWidget {
  int index = 0;

  ///当前选中状态
  bool checked;

  ///是否选择条目
  bool isSelect;
  Function(int, bool) onItemTap;

  ListViewItemAlbum(
      {Key? key,
      required this.index,
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
    return GestureDetector(
      onTap: (){
        widget.checked = !widget.checked;
        widget.onItemTap(widget.index,widget.checked);
        setState(() {});
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showImg(SDUtils.getImgPath("ic_head.jpg"),
              width: double.infinity, fit: BoxFit.cover, hasShadow: false),
          SizedBox(
            height: 5.w,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "だから僕ら…",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15.sp,
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
                        widget.onItemTap(widget.index,checked);
                      }),
                ),
              )
            ],
          ),
          Text(
            "Liella!",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}
