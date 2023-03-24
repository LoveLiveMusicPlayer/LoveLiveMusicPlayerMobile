import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'de.dart';
import 'en.dart';
import 'zh.dart';

class Translation extends Translations {
  static Locale get locale => Get.deviceLocale ?? const Locale("zh", "CN");
  static const fallbackLocale = Locale("zh", "CN");

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'zh_CN': zhCN,
        'de_DE': deDE,
      };
}
