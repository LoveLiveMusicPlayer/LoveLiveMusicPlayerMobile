import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/main/logic.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

import '../../../utils/sd_utils.dart';

class ListViewItemAlbum extends StatelessWidget {
  int index = 0;

  ListViewItemAlbum({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var logic = Get.find<MainLogic>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ClipRRect(
        //     borderRadius: BorderRadius.circular(8.h),
        //     child: Image.file(SDUtils.getImgFile("ic_head.jpg"),
        //       width: double.infinity,fit: BoxFit.cover,)),
        showImg(SDUtils.getImgPath("ic_head.jpg"),width: double.infinity,height:null,fit: BoxFit.cover,hasShadow: false),
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
              visible: true,
              child: Padding(
                padding: EdgeInsets.only(left: 5.h),
                child: CircularCheckBox(
                    uncheckedIconColor: const Color(0xff999999),
                    checkIconColor: const Color(0xFFF940A7),
                    onCheckd: (checked){

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
    );
  }
}
