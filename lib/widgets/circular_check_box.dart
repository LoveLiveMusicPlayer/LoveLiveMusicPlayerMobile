import 'package:flutter/material.dart';

class CircularCheckBox extends StatefulWidget {
  bool checkd;
  final Color checkIconColor;
  final Color uncheckedIconColor;
  final double iconSize;
  final String title;
  final double spacing;
  final Function(bool) onCheckd;
  final TextStyle textStyle;

  CircularCheckBox(
      {Key? key,
      this.checkd = false,
      this.checkIconColor = Colors.red,
      this.uncheckedIconColor = Colors.black54,
      this.iconSize = 20,
      this.title = "",
      this.textStyle = const TextStyle(color: Colors.black54, fontSize: 20),
      this.spacing = 0,
      required this.onCheckd})
      : super(key: key);

  @override
  State<CircularCheckBox> createState() => _CircularCheckBoxState();
}

class _CircularCheckBoxState extends State<CircularCheckBox> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          widget.checkd = !widget.checkd;
          widget.onCheckd(widget.checkd);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.checkd
                ? Icons.check_circle
                : Icons.radio_button_unchecked_outlined,
            color: widget.checkd
                ? widget.checkIconColor
                : widget.uncheckedIconColor,
            size: widget.iconSize,
          ),
          SizedBox(
            width: widget.spacing,
          ),
          Text(
            widget.title,
            style: widget.textStyle,
          )
        ],
      ),
    );
  }
}
