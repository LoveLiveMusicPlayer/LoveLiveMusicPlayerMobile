import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageViewLogic extends GetxController {
    final controller = PageController();

    static PageViewLogic get to => Get.find();
}
