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

  static bool checkFileExist(String filePath) {
    var file = File(filePath);
    return file.existsSync();
  }

  static void makeDir(String dir) {
    var file = Directory(dir);
    try {
      bool exists = file.existsSync();
      if (!exists) {
        file.createSync(recursive: true);
      }
    } catch (e) {
      print(e);
    }
  }
}
