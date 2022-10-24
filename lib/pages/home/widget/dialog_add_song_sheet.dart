import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/widget/listview_item_song_sheet.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/new_menu_dialog.dart';

class DialogAddSongSheet extends StatelessWidget {
  final List<Music> musicList;
  final Function(bool)? changeLoveStatusCallback;

  const DialogAddSongSheet(
      {Key? key, required this.musicList, this.changeLoveStatusCallback})
      : super(key: key);

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
            child: Text("添加到歌单",
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
          _buildItem("新建歌单", true, () {
            SmartDialog.compatible.dismiss();
            SmartDialog.compatible.show(
                widget: NewMenuDialog(
                    title: "新建歌单",
                    onConfirm: (name) async {
                      final idList = <String>[];
                      for (var music in musicList) {
                        final id = music.musicId;
                        if (id != null) {
                          idList.add(id);
                        }
                      }
                      bool isSuccess = await DBLogic.to.addMenu(name, idList);
                      SmartDialog.compatible
                          .showToast(isSuccess ? "新建成功" : "超出最大数量");
                    }),
                clickBgDismissTemp: false,
                alignmentTemp: Alignment.center);
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
                        SmartDialog.compatible.dismiss();
                        SmartDialog.compatible
                            .showToast(isSuccess ? "添加成功" : "添加失败");
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
    return _buildItem("我喜欢", true, () {
      PlayerLogic.to.toggleLoveList(musicList, notAllLove);
      SmartDialog.compatible.dismiss();
      SmartDialog.compatible.showToast(notAllLove ? "已加入我喜欢" : "已取消我喜欢");
      if (changeLoveStatusCallback != null) {
        changeLoveStatusCallback!(notAllLove);
      }
    },
        assetPath: notAllLove ? Assets.playerPlayLove : null,
        icon: notAllLove ? null : Icons.favorite);
  }

  ///单个条目
  Widget _buildItem(String title, bool showLin, GestureTapCallback? onTap,
      {String? assetPath, IconData? icon}) {
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
                  child: Text(title,
                      style: Get.isDarkMode
                          ? TextStyleMs.white_15
                          : TextStyleMs.lightBlack_15),
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
      return touchIconByAsset(
          path: assetPath,
          width: 16.h,
          height: 16.h,
          color: Get.isDarkMode ? Colors.white : ColorMs.color666666);
    } else if (icon != null) {
      return touchIcon(icon, () {}, color: Colors.pinkAccent);
    } else {
      return const SizedBox();
    }
  }
}
