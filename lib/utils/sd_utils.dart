import 'dart:io';
import 'dart:isolate';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/device.dart';
import 'package:lovelivemusicplayer/models/download_splash.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:path_provider/path_provider.dart';

class SDUtils {
  static String path = "";
  static bool allowEULA = false;
  static late String bgPhotoPath;
  static late String splashPhotoPath;

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
    splashPhotoPath = "${path}splash/";
    if (!checkDirectoryExist(splashPhotoPath)) {
      makeDir(splashPhotoPath);
    }
    allowEULA = Platform.isAndroid || checkDirectoryExist("${path}LLMP");
    Log4f.d(msg: path);
  }

  ///从路径中获取图片文件
  static File getImgFile(String fileName) {
    return File(path + fileName);
  }

  ///从路径中获取图片完整路径
  static String getImgPath({String? fileName}) {
    return path + (fileName ?? "");
  }

  ///从music中获取图片完整路径
  static String? getImgPathFromMusic(Music music) {
    String? imagePath;
    if (music.musicId == null) {
      return "";
    }
    if (music.existFile == true) {
      imagePath = "$path${music.baseUrl}${music.coverPath}";
    } else if (remoteHttp.canUseHttpUrl()) {
      imagePath =
          "${remoteHttp.httpUrl.value}${music.baseUrl}${music.coverPath}";
    }
    return imagePath;
  }

  static Future<String?> getImgPathFromMusicId(String musicId) async {
    final music = await DBLogic.to.musicDao.findMusicByUId(musicId);
    if (music == null) {
      return null;
    }
    return getImgPathFromMusic(music);
  }

  ///从album中获取图片完整路径
  static String? getImgPathFromAlbum(Album album) {
    String? imagePath;
    if (album.existFile == true) {
      imagePath = "$path${album.coverPath}";
    } else if (remoteHttp.canUseHttpUrl()) {
      imagePath = "${remoteHttp.httpUrl.value}${album.coverPath}";
    }
    return imagePath;
  }

  static bool checkFileExist(String filePath) {
    var file = File(filePath);
    return file.existsSync();
  }

  static bool checkMusicExist(Music music) {
    if (music.existFile == true) {
      final filePath = '${SDUtils.path}${music.baseUrl}${music.musicPath}';
      return SDUtils.checkFileExist(filePath);
    } else if (remoteHttp.canUseHttpUrl()) {
      return true;
    } else {
      return false;
    }
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
      Log4f.i(msg: e.toString());
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
      Log4f.i(msg: e.toString());
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
      Log4f.i(msg: e.toString());
    }
  }

  static List<String> getSplashPhotoList() {
    final photoList = <String>[];
    try {
      var dir = Directory(splashPhotoPath);
      dir.listSync().forEach((element) {
        photoList.add(element.path);
      });
    } catch (e) {
      Log4f.i(msg: e.toString());
    }
    return photoList;
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
      Log4f.i(msg: e.toString());
    }
  }

  static Future<Device> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      return Device(
          physicalDevice: info.isPhysicalDevice,
          serialNo: info.device,
          brand: info.brand,
          model: info.model,
          osName: info.version.baseOS ?? "",
          osVersion: "${info.version.sdkInt}");
    } else {
      final info = await deviceInfoPlugin.iosInfo;
      return Device(
          physicalDevice: info.isPhysicalDevice,
          serialNo: info.identifierForVendor ?? "",
          brand: info.localizedModel,
          model: info.utsname.machine,
          osName: info.utsname.sysname,
          osVersion: info.systemVersion);
    }
  }

  // 遍历目录下全部文件
  static List<String> recursionFile(String dirPath, {recursion = false}) {
    Directory dir = Directory(dirPath);
    List<String> filePathList = [];

    if (dir.existsSync()) {
      List<FileSystemEntity> lists = dir.listSync();
      for (FileSystemEntity entity in lists) {
        if (entity is File) {
          filePathList.add(entity.path);
        } else if (entity is Directory && recursion) {
          Directory subDir = entity;
          recursionFile(subDir.path);
        }
      }
    }

    return filePathList;
  }

  static void downloadSplashList(List<DownloadSplash> downloadList) {
    print("downloadSplashList: ${downloadList.length}");
    if (downloadList.isNotEmpty) {
      Isolate.spawn(downloadFiles, downloadList);
    }
  }

  static void downloadFiles(List<DownloadSplash> downloadList) async {
    for (var item in downloadList) {
      try {
        final response = await http.get(Uri.parse(item.url));
        if (response.statusCode == 200) {
          // 保存图片到本地
          var file = File(item.filePath);
          file.writeAsBytesSync(response.bodyBytes);
          print('图片下载成功');
        } else {
          print('图片下载失败: code=${response.statusCode}');
        }
      } catch (e) {
        Log4f.i(msg: e.toString());
      }
    }
  }
}
