import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

///歌单
class ListViewItemSongSheet extends StatefulWidget {
  Function(Menu) onItemTap;

  ///条目数据
  Menu menu;

  Function(Menu)? onMoreTap;

  ListViewItemSongSheet(
      {Key? key, required this.onItemTap, this.onMoreTap, required this.menu})
      : super(key: key);

  @override
  State<ListViewItemSongSheet> createState() => _ListViewItemSongStateSheet();
}

class _ListViewItemSongStateSheet extends State<ListViewItemSongSheet>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InkWell(
      onTap: () => widget.onItemTap(widget.menu),
      child: Container(
        color: Get.theme.primaryColor,
        child: Row(
          children: [
            ///缩列图
            _buildIcon(),
            //
            SizedBox(
              width: 10.w,
            ),

            ///中间标题部分
            _buildContent(),

            ///右侧操作按钮
            _buildAction()
          ],
        ),
      ),
    );
  }

  ///缩列图
  Widget _buildIcon() {
    return FutureBuilder<String>(
      initialData: SDUtils.getImgPath(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return showImg(snapshot.data, 48, 48, hasShadow: false, radius: 8, onTap: () => widget.onItemTap(widget.menu));
      },
      future: AppUtils.getMusicCoverPath(widget.menu.music?.last),
    );
  }

  ///中间标题部分
  Widget _buildContent() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.menu.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  Get.isDarkMode ? TextStyleMs.white_15 : TextStyleMs.black_15),
          SizedBox(
            height: 4.w,
          ),
          Text(
            "${widget.menu.music?.length ?? 0}首",
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
    return Visibility(
      visible: widget.onMoreTap != null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              widget.onMoreTap!(widget.menu);
            },
            child: Container(
              padding: EdgeInsets.only(
                  left: 12.w, right: 10.w, top: 12.h, bottom: 12.h),
              child: touchIconByAsset(
                  path: Assets.mainIcMore,
                  width: 10,
                  height: 20,
                  color: const Color(0xFFCCCCCC)),
            ),
          ),
          SizedBox(width: 4.w)
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
