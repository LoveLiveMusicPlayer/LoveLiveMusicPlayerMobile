import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SdUtils {
  static String path = "";

  static init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    path = appDocDir.path + "/";
  }

  ///获取图片文件
  static File getImgFile(String fileName) {
    return File(path + fileName);
  }

  ///获取图片文件
  static String getImgPath(String fileName) {
    return path + fileName;
  }
}
