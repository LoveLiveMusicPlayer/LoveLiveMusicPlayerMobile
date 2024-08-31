import 'package:flutter/material.dart';

class CircularCheckBox extends StatefulWidget {
  bool checked;
  final Color checkIconColor;
  final Color uncheckedIconColor;
  final double iconSize;
  final String title;
  final double spacing;
  final Function(bool) onChecked;
  final TextStyle textStyle;

  CircularCheckBox(
      {super.key,
      this.checked = false,
      this.checkIconColor = Colors.red,
      this.uncheckedIconColor = Colors.black54,
      this.iconSize = 20,
      this.title = "",
      this.textStyle = const TextStyle(color: Colors.black54, fontSize: 20),
      this.spacing = 0,
      required this.onChecked});

  @override
  State<CircularCheckBox> createState() => _CircularCheckBoxState();
}

class _CircularCheckBoxState extends State<CircularCheckBox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.checked = !widget.checked;
          widget.onChecked(widget.checked);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.checked
                ? Icons.check_circle
                : Icons.radio_button_unchecked_outlined,
            color: widget.checked
                ? widget.checkIconColor
                : widget.uncheckedIconColor,
            size: widget.iconSize,
          ),
          SizedBox(width: widget.spacing),
          Text(
            widget.title,
            style: widget.textStyle,
          )
        ],
      ),
    );
  }
}
