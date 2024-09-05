import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

///歌单
class ListViewItemSongSheet extends StatelessWidget {
  final Function(Menu) onItemTap;

  ///条目数据
  final Menu menu;

  final Function(Menu)? onMoreTap;

  final bool? showDevicePic;

  const ListViewItemSongSheet(
      {super.key,
      required this.onItemTap,
      this.onMoreTap,
      required this.menu,
      this.showDevicePic});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onItemTap(menu),
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            _buildDevicePic(),

            SizedBox(width: 5.w),

            ///缩列图
            Hero(tag: "menu${menu.id}", child: _buildIcon()),

            SizedBox(width: 10.w),

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
    if (menu.music.isNotEmpty) {
      return FutureBuilder<String?>(
        initialData: SDUtils.getImgPath(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          return showImg(snapshot.data, 48, 48,
              hasShadow: false, onTap: () => onItemTap(menu));
        },
        future: AppUtils.getMusicCoverPath(menu.music.first),
      );
    } else {
      return showImg(null, 48, 48,
          hasShadow: false, onTap: () => onItemTap(menu));
    }
  }

  Widget _buildDevicePic() {
    final colorFilter = ColorFilter.mode(ColorMs.colorF940A7, BlendMode.srcIn);
    if (showDevicePic == true) {
      if (menu.id <= 100) {
        return SvgPicture.asset(Assets.syncIconComputer,
            colorFilter: colorFilter, width: 13.h, height: 20.h);
      } else {
        return SvgPicture.asset(Assets.syncIconPhone,
            colorFilter: colorFilter, width: 13.h, height: 20.h);
      }
    }
    return Container();
  }

  ///中间标题部分
  Widget _buildContent() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(menu.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GlobalLogic.to.bgPhoto.value != "" || Get.isDarkMode
                  ? TextStyleMs.white_15
                  : TextStyleMs.lightBlack_15),
          SizedBox(height: 4.h),
          Text(
            "${menu.music.length} ${'total_number_unit'.tr}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyleMs.f12_400.copyWith(
                color: GlobalLogic.to.bgPhoto.value == ""
                    ? ColorMs.color999999
                    : ColorMs.colorD6D6D6),
          ),
          SizedBox(width: 16.h)
        ],
      ),
    );
  }

  ///右侧操作按钮
  Widget _buildAction() {
    final color = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? ColorMs.colorDFDFDF
        : ColorMs.colorCCCCCC;
    return Visibility(
      visible: onMoreTap != null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          neumorphicButton(Assets.mainIcMore, () => onMoreTap!(menu),
              width: 30,
              height: 30,
              iconColor: color,
              hasShadow: false,
              margin: EdgeInsets.symmetric(vertical: 12.h)),
          SizedBox(width: 4.w)
        ],
      ),
    );
  }
}
