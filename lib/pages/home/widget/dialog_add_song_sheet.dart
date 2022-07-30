import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_song_sheet.dart';
import 'package:lovelivemusicplayer/widgets/new_menu_dialog.dart';

import '../../../modules/ext.dart';

class DialogAddSongSheet extends StatelessWidget {
  final Music music;

  const DialogAddSongSheet({Key? key, required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          boxShadow: [
            BoxShadow(
                color: Get.theme.primaryColor, blurRadius: 4, spreadRadius: 4)
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h))),
      height: 450.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.h),
            child: Text(
              "添加到歌单",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      Get.isDarkMode ? Colors.white : const Color(0xff333333)),
            ),
          ),
          Divider(
            height: 0.5.h,
            color: Get.isDarkMode
                ? const Color(0xFF737373)
                : const Color(0xFFCFCFCF),
          ),
          _buildItem("新建歌单", true, () {
            SmartDialog.dismiss();
            SmartDialog.compatible.show(
                widget: NewMenuDialog(
                    title: "新建歌单",
                    onConfirm: (name) {
                      DBLogic.to.addMenu(name, [music.musicId!]);
                    }),
                clickBgDismissTemp: false,
                alignmentTemp: Alignment.center);
          }, assetPath: Assets.dialogIcNewSongList),
          renderLove(),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 16.w, top: 12.h, right: 16.w),
            child: ListView.separated(
                itemCount: GlobalLogic.to.menuList.length,
                padding: const EdgeInsets.all(0),
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.transparent,
                    height: 10.h,
                  );
                },
                itemBuilder: (cxt, index) {
                  return ListViewItemSongSheet(
                    onItemTap: (menu) {
                      DBLogic.to.insertToMenu(
                          GlobalLogic.to.menuList[index].id, [music.musicId!]);
                      SmartDialog.dismiss();
                    },
                    menu: GlobalLogic.to.menuList[index],
                  );
                }),
          ))
        ],
      ),
    );
  }

  Widget renderLove() {
    if (music.isLove) {
      return _buildItem("我喜欢", true, () {
        PlayerLogic.to.toggleLove(music: music, isLove: false);
        SmartDialog.dismiss();
      }, icon: Icons.favorite);
    } else {
      return _buildItem("我喜欢", true, () {
        PlayerLogic.to.toggleLove(music: music, isLove: true);
        SmartDialog.dismiss();
      }, assetPath: Assets.playerPlayLove);
    }
  }

  ///单个条目
  Widget _buildItem(String title, bool showLin, GestureTapCallback? onTap, {String? assetPath, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h, right: 16.h),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 14.h,
            ),
            Row(
              children: [
                renderIcon(assetPath, icon),
                SizedBox(
                  width: 10.h,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: Get.isDarkMode
                            ? Colors.white
                            : const Color(0xff666666),
                        fontSize: 15.sp),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 14.h,
            ),
            Visibility(
              visible: showLin,
              child: Divider(
                height: 0.5.h,
                color: Get.isDarkMode
                    ? const Color(0xFF737373)
                    : const Color(0xFFCFCFCF),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget renderIcon(String? assetPath, IconData? icon) {
    if (assetPath != null) {
      return touchIconByAsset(
          path: assetPath,
          width: 16.h,
          height: 16.h,
          color: Get.isDarkMode
              ? Colors.white
              : const Color(0xFF666666));
    } else if (icon != null) {
      return touchIcon(
          icon, () {},
          color: Colors.pinkAccent
      );
    } else {
      return const SizedBox();
    }
  }
}
