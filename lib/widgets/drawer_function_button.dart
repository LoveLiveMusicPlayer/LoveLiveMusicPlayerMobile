import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

class DrawerFunctionButton extends StatefulWidget {
  const DrawerFunctionButton(
      {Key? key,
      this.icon,
      required this.text,
      this.onTap,
      this.hasSwitch = false,
      this.initSwitch = false,
      this.enableSwitch = true,
      this.colorWithBG = true,
      this.iconColor,
      this.callBack})
      : super(key: key);

  final String? icon;
  final String text;
  final GestureTapCallback? onTap;
  final bool colorWithBG;
  final Color? iconColor;
  final bool hasSwitch;
  final bool initSwitch;
  final bool enableSwitch;
  final Callback? callBack;

  @override
  State<DrawerFunctionButton> createState() => _DrawerFunctionButtonState();
}

typedef Callback = void Function(bool check);

class _DrawerFunctionButtonState extends State<DrawerFunctionButton> {
  late bool switchValue = widget.initSwitch;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        child: SizedBox(
          height: 30.h,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Row(
              children: [
                widget.icon != null
                    ? SvgPicture.asset(widget.icon!,
                        height: 20.h, width: 20.h, color: widget.iconColor)
                    : SizedBox(height: 20.h, width: 20.h),
                SizedBox(width: 8.r),
                Expanded(child: GetBuilder<GlobalLogic>(builder: (logic) {
                  late bool mode;
                  if (widget.colorWithBG) {
                    mode = Get.isDarkMode || logic.bgPhoto.value != "";
                  } else {
                    mode = Get.isDarkMode;
                  }
                  return Text(widget.text,
                      style: TextStyle(fontSize: 14.sp).copyWith(
                          color: mode ? ColorMs.colorEDF5FF : Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis);
                }))
              ],
            )),
            renderSwitchButton()
          ]),
        ));
  }

  Widget renderSwitchButton() {
    if (widget.hasSwitch) {
      if (widget.enableSwitch) {
        return Transform.scale(
          scale: 0.9,
          child: CupertinoSwitch(
              value: switchValue,
              activeColor: const Color.fromARGB(255, 228, 0, 127),
              onChanged: (value) {
                switchValue = value;
                if (widget.callBack != null) {
                  widget.callBack!(value);
                }
                setState(() {});
              }),
        );
      } else {
        return Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: switchValue,
              activeColor: const Color.fromARGB(255, 228, 0, 127),
              onChanged: null,
            ));
      }
    } else {
      return Container();
    }
  }
}
