import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

class ListViewItemSinger extends StatelessWidget {
  const ListViewItemSinger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right:  10.h),
          child: CircularCheckBox(onCheckd: (checked){

          }),
        ),
        showImg(SDUtils.getImgPath("ic_head.jpg"),
            width: 48.h, height: 48.h, radius: 24.h, hasShadow: false),
        SizedBox(
          width: 10.h,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "だから僕ら…",
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
        ),
        SizedBox(
          width: 10.h,
        ),
      ],
    );
  }
}
