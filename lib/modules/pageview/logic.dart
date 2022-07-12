import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageViewLogic extends GetxController {
  final controller = PageController();

  var canScroll = true.obs;

  static PageViewLogic get to => Get.find();
}
