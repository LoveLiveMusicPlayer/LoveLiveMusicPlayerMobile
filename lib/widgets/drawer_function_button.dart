import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

class DrawerFunctionButton extends StatefulWidget {
  const DrawerFunctionButton(
      {super.key,
      this.icon,
      this.text = "",
      this.onTap,
      this.hasSwitch = false,
      this.initSwitch = false,
      this.enableSwitch = true,
      this.colorWithBG = true,
      this.iconColor,
      this.controller,
      this.callBack});

  final String? icon;
  final String text;
  final GestureTapCallback? onTap;
  final bool colorWithBG;
  final Color? iconColor;
  final bool hasSwitch;
  final bool initSwitch;
  final bool enableSwitch;
  final Callback? callBack;
  final ButtonController? controller;

  @override
  State<DrawerFunctionButton> createState() => _DrawerFunctionButtonState();
}

typedef Callback = void Function(ButtonController controller, bool check);
typedef GestureTapCallback = void Function(ButtonController controller);

class ButtonController extends ChangeNotifier {
  late String _textValue;
  late bool _switchValue;

  ButtonController(this._textValue, this._switchValue);

  String get getText => _textValue;

  bool get getSwitchValue => _switchValue;

  set setSwitchValue(bool newValue) {
    if (_switchValue != newValue) {
      _switchValue = newValue;
      notifyListeners();
    }
  }

  set setTextValue(String newValue) {
    if (_textValue != newValue) {
      _textValue = newValue;
      notifyListeners();
    }
  }
}

class _DrawerFunctionButtonState extends State<DrawerFunctionButton> {
  late ButtonController bh =
      widget.controller ?? ButtonController(widget.text, widget.initSwitch);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => widget.onTap?.call(bh),
        child: SizedBox(
          height: 30.h,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Row(
              children: [
                widget.icon != null
                    ? neumorphicButton(widget.icon!, null,
                        width: 28, height: 28, iconColor: widget.iconColor)
                    : SizedBox(height: 28.h, width: 28.h),
                SizedBox(width: 8.w),
                Expanded(child: GetBuilder<GlobalLogic>(builder: (logic) {
                  late bool mode;
                  if (widget.colorWithBG) {
                    mode = Get.isDarkMode || logic.bgPhoto.value != "";
                  } else {
                    mode = Get.isDarkMode;
                  }
                  return ListenableBuilder(
                      listenable: bh,
                      builder: (c, w) => Text(bh._textValue,
                          style: TextStyle(fontSize: 15.h).copyWith(
                              color: mode ? ColorMs.colorEDF5FF : Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis));
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
          scale: 0.8,
          child: ListenableBuilder(
              listenable: bh,
              builder: (c, w) => NeumorphicSwitch(
                    value: bh._switchValue,
                    style: const NeumorphicSwitchStyle(
                        thumbShape: NeumorphicShape.concave),
                    onChanged: (value) {
                      bh.setSwitchValue = value;
                      widget.callBack?.call(bh, value);
                    },
                  )),
        );
      } else {
        return Transform.scale(
            scale: 0.8,
            child: NeumorphicSwitch(
              value: bh._switchValue,
              style: const NeumorphicSwitchStyle(
                  thumbShape: NeumorphicShape.concave),
              onChanged: null,
            ));
      }
    } else {
      return Container();
    }
  }
}
