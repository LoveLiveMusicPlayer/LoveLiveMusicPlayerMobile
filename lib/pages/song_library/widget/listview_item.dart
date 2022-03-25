import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

class ListViewItem extends StatefulWidget {
  Function(bool) onItemTap;
  Function() onPlayTap;
  Function() onMoreTap;

  ListViewItem(
      {Key? key,
      required this.onItemTap,
      required this.onPlayTap,
      required this.onMoreTap})
      : super(key: key);

  @override
  State<ListViewItem> createState() => _ListViewItemState();
}

class _ListViewItemState extends State<ListViewItem> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onItemTap(checked);
      },
      child: SizedBox(
        height: 68.w,
        child: Row(
          children: [
            SizedBox(
              width: 10.w,
            ),

            ///勾选按钮
            _buildCheckBox(),
            SizedBox(
              width: 6.w,
            ),

            ///缩列图
            _buildIcon(),
            SizedBox(
              width: 10.w,
            ),

            ///中间标题部分
            _buildContent(),

            ///右侧操作按钮
            _buildAction(),
          ],
        ),
      ),
    );
  }

  ///缩列图
  Widget _buildIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.w),
      child: Image.file(
        SdUtils.getImgFile("ic_head.jpg"),
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
      ),
    );
  }

  ///勾选按钮
  Widget _buildCheckBox() {
    return Padding(
      padding: EdgeInsets.only(left: 6.w, right: 4.w),
      child: CircularCheckBox(
        onCheckd: (value) {
          checked = value;
          widget.onItemTap(checked);
        },
        checkIconColor: Color(0xFFF940A7),
        uncheckedIconColor: Color(0xFF999999),
      ),
    );
  }

  ///中间标题部分
  Widget _buildContent() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "START！！True dreams",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: const Color(0xff333333),
                fontSize: 15.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 4.w,
          ),
          Text(
            "Liella!",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xff999999),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(
            width: 16.w,
          )
        ],
      ),
    );
  }

  ///右侧操作按钮
  Widget _buildAction() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            widget.onPlayTap();
          },
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Image.asset(
              "assets/main/ic_play.jpg",
              width: 20.w,
              height: 20.w,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.onMoreTap();
          },
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Image.asset(
              "assets/main/ic_more.jpg",
              width: 20.w,
              height: 20.w,
            ),
          ),
        ),
        SizedBox(
          width: 4.w,
        )
      ],
    );
  }
}
