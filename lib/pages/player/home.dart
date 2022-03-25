import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = ScrollController();
  final ValueNotifier<double> _opacity = ValueNotifier<double>(1.0);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_opacity.value == 1.0 && _controller.offset > 20) {
        _opacity.value = 0.0;
      } else if (_opacity.value == 0.0 && _controller.offset < 20) {
        _opacity.value = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorTheme = Theme.of(context).colorScheme;
    return Container(
      width: size.width,
      height: size.height + 100,
      color: colorTheme.background,
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _opacity,
            builder: (_, __, ___) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _opacity.value,
                child: SizedBox(
                  height: 90,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [],
                  ),
                ),
              );
            },
          ),
          ListView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            children: [],
          ),
        ],
      ),
    );
  }
}
