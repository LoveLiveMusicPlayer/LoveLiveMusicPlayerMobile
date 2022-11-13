import 'dart:io';
import 'dart:typed_data';

import 'package:common_utils/common_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/models/Device.dart';
import 'package:path_provider/path_provider.dart';

class SDUtils {
  static String path = "";
  static bool allowEULA = false;

  static init() async {
    Directory? appDocDir;
    if (Platform.isAndroid) {
      appDocDir = await getExternalStorageDirectory();
    }
    appDocDir ??= await getApplicationDocumentsDirectory();
    path = appDocDir.path + Platform.pathSeparator;
    allowEULA = SDUtils.checkDirectoryExist("${SDUtils.path}LLMP");
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
      Log4f.e(msg: e.toString(), writeFile: true);
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
      Log4f.e(msg: e.toString(), writeFile: true);
    }
  }

  static uploadLog() async {
    final time = DateUtil.getNowDateStr();
    final loggerFile =
        File(await FlutterLogan.getUploadPath(time.split(" ")[0]));
    if (loggerFile.existsSync()) {
      final filePath = "${path}log${Platform.pathSeparator}$time.txt";
      touchFile(filePath);
      loggerFile.copySync(filePath);
    }
    final device = await getDeviceInfo();
    final deviceFilePath = "${path}log${Platform.pathSeparator}device.txt";
    if (!File(deviceFilePath).existsSync()) {
      touchFile(deviceFilePath);
    }
    final deviceJson = deviceToJson(device).codeUnits;
    File(deviceFilePath)
        .writeAsBytesSync(Uint8List.fromList(deviceJson), flush: true);
  }

  static Future<Device> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      return Device(
          physicalDevice: info.isPhysicalDevice ?? false,
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
