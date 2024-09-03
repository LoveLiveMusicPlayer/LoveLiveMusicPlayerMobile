import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/text_field_dialog.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';

class DialogMoreWithMenu extends StatelessWidget {
  final Menu menu;

  const DialogMoreWithMenu({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4 * 55.h,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          boxShadow: [
            BoxShadow(
                color: Get.theme.primaryColor, blurRadius: 4, spreadRadius: 4)
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h))),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.h),
            child: Text(menu.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Get.isDarkMode
                    ? TextStyleMs.white_17
                    : TextStyleMs.black_17),
          ),
          Divider(
            height: 0.5.h,
            color: Get.isDarkMode ? ColorMs.color737373 : ColorMs.colorCFCFCF,
          ),
          _buildItem(Assets.dialogIcEdit, 'rename_menu'.tr, true, () {
            SmartDialog.dismiss();
            SmartDialog.show(
                clickMaskDismiss: false,
                alignment: Alignment.center,
                builder: (context) {
                  return TextFieldDialog(
                      title: 'rename_menu'.tr,
                      hint: 'input_menu_name'.tr,
                      onConfirm: (name) {
                        DBLogic.to.updateMenuName(name, menu.id);
                      });
                });
          }),
          _buildItem(Assets.dialogIcDelete2, 'delete_menu'.tr, true, () {
            SmartDialog.dismiss();
            SmartDialog.show(builder: (context) {
              return TwoButtonDialog(
                title: 'warning_choose'.tr,
                msg: 'need_delete_menu'.tr,
                onConfirmListener: () {
                  DBLogic.to.deleteMenuById(menu.id);
                },
              );
            });
          }),
          _buildItem(Assets.drawerDrawerShare, 'share_menu'.tr, false, () {
            SmartDialog.dismiss();
            AppUtils.shareQQ(menu: menu);
          }),
        ],
      ),
    );
  }

  ///单个条目
  Widget _buildItem(
      String path, String title, bool showLin, GestureTapCallback? onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h, right: 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Row(
              children: [
                neumorphicButton(
                  path,
                  onTap,
                  width: 26,
                  height: 26,
                  iconColor:
                      Get.isDarkMode ? Colors.white : ColorMs.color666666,
                  hasShadow: false,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: Get.isDarkMode
                        ? TextStyleMs.white_15
                        : TextStyleMs.lightBlack_15,
                  ),
                )
              ],
            ),
            SizedBox(height: 12.h),
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
}
