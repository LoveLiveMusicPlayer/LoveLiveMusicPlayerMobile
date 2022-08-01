import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class NewMenuDialog extends StatefulWidget {
  final String? title;
  final Function()? onBack;
  final Function(String str)? onConfirm;

  const NewMenuDialog({Key? key, this.title, this.onBack, this.onConfirm})
      : super(key: key);

  @override
  State<NewMenuDialog> createState() => _NewMenuDialogState();
}

class _NewMenuDialogState extends State<NewMenuDialog> {
  final controller = TextEditingController();
  String text = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.primaryColor,
      width: 250.w,
      height: 180.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
            child: Text(widget.title ?? "标题",
                style: Get.isDarkMode
                    ? TextStyleMs.white_18
                    : TextStyleMs.black_18),
          ),
          SizedBox(
            width: 200.w,
            child: Center(
              widthFactor: 200.w,
              child: TextField(
                  controller: controller,
                  cursorColor: Colors.blue,
                  cursorHeight: 18.h,
                  cursorRadius: Radius.circular(15.r),
                  cursorWidth: 2,
                  showCursor: true,
                  obscureText: false,
                  maxLength: 12,
                  decoration: InputDecoration(
                      isCollapsed: false,
                      labelText: "请输入歌单名",
                      contentPadding: EdgeInsets.only(left: 8.w, right: 8.w),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red))),
                  onChanged: (str) {
                    final len = str.length;
                    if (len < 12) {
                      text = str.substring(0, len);
                    } else {
                      text = str.substring(0, 12);
                    }

                    controller.value = TextEditingValue(
                        text: text,
                        selection:
                            TextSelection.collapsed(offset: text.length));
                    setState(() {});
                  },
                  textInputAction: TextInputAction.search),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  }
                  SmartDialog.dismiss();
                },
                child: Container(
                  color: Colors.red,
                  width: 125.w,
                  height: 45.h,
                  child: const Center(
                    child: Text("取消"),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (widget.onConfirm != null) {
                    widget.onConfirm!(text);
                  }
                  SmartDialog.dismiss();
                },
                child: Container(
                    color: Colors.green,
                    width: 125.w,
                    height: 45.h,
                    child: const Center(
                      child: Text("确定"),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}
