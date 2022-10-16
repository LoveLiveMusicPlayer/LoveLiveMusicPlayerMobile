import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class DrawerFunctionButton extends StatefulWidget {
  const DrawerFunctionButton(
      {Key? key,
      required this.icon,
      required this.text,
      this.onTap,
      this.hasSwitch = false,
      this.initSwitch = false,
      this.enableSwitch = true,
      this.callBack})
      : super(key: key);

  final String icon;
  final String text;
  final GestureTapCallback? onTap;
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
            Row(
              children: [
                SvgPicture.asset(widget.icon, height: 20.h, width: 20.h),
                SizedBox(width: 8.w),
                Text(widget.text, style: TextStyle(fontSize: 15.sp))
              ],
            ),
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
              onChanged: null,
            ));
      }
    } else {
      return Container();
    }
  }
}
