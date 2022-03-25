import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class MyPage extends StatelessWidget {
  final logic = Get.put(MyLogic());
  final state = Get.find<MyLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
