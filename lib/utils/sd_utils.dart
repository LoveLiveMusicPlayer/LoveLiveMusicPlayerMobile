import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:path_provider/path_provider.dart';

class SDUtils {
  static String path = "";

  static init() async {
    Directory? appDocDir;
    if (Platform.isAndroid) {
      appDocDir = await getExternalStorageDirectory();
    }
    appDocDir ??= await getApplicationDocumentsDirectory();
    path = appDocDir.path + Platform.pathSeparator;
    LogUtil.e(path);
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
