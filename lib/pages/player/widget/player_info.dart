import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/Music.dart';
import '../../test/logic.dart';

class PlayerInfo extends StatelessWidget {

  var logic = Get.find<TestLogic>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}