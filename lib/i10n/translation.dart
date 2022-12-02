import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'en_US.dart';
import 'zh_CN.dart';
import 'de_DE.dart';

class Translation extends Translations {
  static Locale get locale => Get.deviceLocale ?? const Locale("zh", "CN");
  static const fallbackLocale = Locale("zh", "CN");

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en_US,
        'zh_CN': zh_CN,
        'de_DE': de_DE,
      };
}
