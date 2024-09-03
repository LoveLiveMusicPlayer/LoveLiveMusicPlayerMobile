import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_song_sheet.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/text_field_dialog.dart';

class DialogAddSongSheet extends StatelessWidget {
  final List<Music> musicList;
  final Function(bool)? changeLoveStatusCallback;
  final Function(bool)? changeMenuStateCallback;

  const DialogAddSongSheet(
      {super.key,
      required this.musicList,
      this.changeLoveStatusCallback,
      this.changeMenuStateCallback});

  @override
  Widget build(BuildContext context) {
    final menuList = [];
    for (var menu in GlobalLogic.to.menuList) {
      if (menu.id > 100) {
        menuList.add(menu);
      }
    }

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
            child: Text('add_to_menu'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.isDarkMode
                    ? TextStyleMs.whiteBold_17
                    : TextStyleMs.blackBold_17),
          ),
          Divider(
            height: 0.5.h,
            color: Get.isDarkMode ? ColorMs.color737373 : ColorMs.colorCFCFCF,
          ),
          _buildItem('create_menu'.tr, true, () {
            SmartDialog.dismiss();
            SmartDialog.show(
                clickMaskDismiss: false,
                alignment: Alignment.center,
                builder: (context) {
                  return TextFieldDialog(
                      title: 'create_menu'.tr,
                      hint: 'input_menu_name'.tr,
                      onConfirm: (name) async {
                        final idList = <String>[];
                        for (var music in musicList) {
                          final id = music.musicId;
                          if (id != null) {
                            idList.add(id);
                          }
                        }
                        bool isSuccess = await DBLogic.to.addMenu(name, idList);
                        SmartDialog.showToast(isSuccess
                            ? 'create_success'.tr
                            : 'create_over_max'.tr);
                        changeMenuStateCallback?.call(isSuccess);
                      });
                });
          }, assetPath: Assets.dialogIcNewSongList),
          renderLove(),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 16.w, top: 12.h, right: 16.w),
            child: ListView.separated(
                itemCount: menuList.length,
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
                      final idList = <String>[];
                      for (var music in musicList) {
                        final id = music.musicId;
                        if (id != null) {
                          idList.add(id);
                        }
                      }
                      DBLogic.to
                          .insertToMenu(menuList[index].id, idList)
                          .then((isSuccess) {
                        SmartDialog.dismiss();
                        SmartDialog.showToast(
                            isSuccess ? 'add_success'.tr : 'add_fail'.tr);
                        changeMenuStateCallback?.call(isSuccess);
                      });
                    },
                    menu: menuList[index],
                  );
                }),
          ))
        ],
      ),
    );
  }

  Widget renderLove() {
    bool notAllLove = musicList.any((music) => music.isLove == false);
    return _buildItem('iLove'.tr, true, () async {
      await PlayerLogic.to.toggleLoveList(musicList, notAllLove);
      SmartDialog.dismiss();
      SmartDialog.showToast(
          notAllLove ? 'add_to_iLove'.tr : 'remove_from_iLove'.tr);
      changeLoveStatusCallback?.call(notAllLove);
    },
        assetPath: notAllLove ? Assets.playerPlayLove : null,
        icon: notAllLove ? null : Icons.favorite);
  }

  ///单个条目
  Widget _buildItem(String title, bool showLin, GestureTapCallback? onTap,
      {String? assetPath, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h, right: 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 14.h),
            Row(
              children: [
                renderIcon(assetPath, icon),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(title,
                      style: Get.isDarkMode
                          ? TextStyleMs.white_15
                          : TextStyleMs.lightBlack_15),
                )
              ],
            ),
            SizedBox(height: 14.w),
            Visibility(
              visible: showLin,
              child: Divider(
                height: 0.5.h,
                color:
                    Get.isDarkMode ? ColorMs.color737373 : ColorMs.colorCFCFCF,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget renderIcon(String? assetPath, IconData? icon) {
    if (assetPath != null) {
      return neumorphicButton(
        assetPath,
        null,
        width: 28,
        height: 28,
        iconColor: Get.isDarkMode ? Colors.white : ColorMs.color666666,
        hasShadow: false,
      );
    } else if (icon != null) {
      return neumorphicButton(icon, null,
          width: 28,
          height: 28,
          iconSize: 20,
          iconColor: Colors.pinkAccent,
          hasShadow: false);
    } else {
      return const SizedBox();
    }
  }
}
