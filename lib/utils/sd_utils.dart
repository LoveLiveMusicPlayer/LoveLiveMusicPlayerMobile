import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/Device.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:path_provider/path_provider.dart';

class SDUtils {
  static String path = "";
  static bool allowEULA = false;
  static late String bgPhotoPath;

  static init() async {
    Directory? appDocDir;
    if (Platform.isAndroid) {
      appDocDir = await getExternalStorageDirectory();
    }
    appDocDir ??= await getApplicationDocumentsDirectory();
    path = appDocDir.path + Platform.pathSeparator;
    bgPhotoPath = "${path}bg/";
    if (!checkDirectoryExist(bgPhotoPath)) {
      makeDir(bgPhotoPath);
    }
    allowEULA = Platform.isAndroid || checkDirectoryExist("${path}LLMP");
    Log4f.d(msg: path);
  }

  ///获取图片文件
  static File getImgFile(String fileName) {
    return File(path + fileName);
  }

  ///获取图片文件
  static String getImgPath({String? fileName}) {
    return path + (fileName ?? "");
  }

  static bool checkFileExist(String filePath) {
    var file = File(filePath);
    return file.existsSync();
  }

  static bool checkDirectoryExist(String dirPath) {
    var dir = Directory(dirPath);
    return dir.existsSync();
  }

  static void makeDir(String dir) {
    var file = Directory(dir);
    try {
      bool exists = file.existsSync();
      if (!exists) {
        file.createSync(recursive: true);
      }
    } catch (e) {
      Log4f.e(msg: e.toString());
    }
  }

  static void touchFile(String filePath) {
    var file = File(filePath);
    try {
      bool exists = file.existsSync();
      if (!exists) {
        file.createSync(recursive: true);
      }
    } catch (e) {
      Log4f.e(msg: e.toString());
    }
  }

  static void saveBGPhoto(String fileName, List<int> content) {
    final filePath = bgPhotoPath + fileName;
    try {
      var dir = Directory(bgPhotoPath);
      dir.listSync().forEach((element) {
        element.deleteSync(recursive: true);
      });
      var file = File(filePath);
      file.writeAsBytesSync(content);
      SpUtil.put(Const.spBackgroundPhoto, fileName);
      GlobalLogic.to.setBgPhoto(filePath);
    } catch (e) {
      Log4f.e(msg: e.toString());
    }
  }

  static clearBGPhotos() {
    try {
      final dir = Directory(bgPhotoPath);
      if (dir.existsSync()) {
        SpUtil.getString(Const.spBackgroundPhoto).then((usingBGPhotoPath) {
          dir.listSync(recursive: false).forEach((file) {
            if (!file.path.contains(usingBGPhotoPath)) {
              file.delete(recursive: true);
            }
          });
        });
      }
    } catch (e) {
      Log4f.e(msg: e.toString());
    }
  }

  static Future<Device> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      return Device(
          physicalDevice: info.isPhysicalDevice,
          serialNo: info.device ?? "",
          brand: info.brand ?? "",
          model: info.model ?? "",
          osName: info.version.baseOS ?? "",
          osVersion: "${info.version.sdkInt}");
    } else {
      final info = await deviceInfoPlugin.iosInfo;
      return Device(
          physicalDevice: info.isPhysicalDevice,
          serialNo: info.identifierForVendor ?? "",
          brand: info.localizedModel ?? "",
          model: info.utsname.machine ?? "",
          osName: info.utsname.sysname ?? "",
          osVersion: info.systemVersion ?? "");
    }
  }
}
