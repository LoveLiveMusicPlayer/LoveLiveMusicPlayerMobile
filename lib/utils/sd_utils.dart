import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
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
  static String getImgPath({String? fileName}) {
    return path + (fileName ?? "");
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

  static void touchFile(String filePath) {
    var file = File(filePath);
    try {
      bool exists = file.existsSync();
      if (!exists) {
        file.createSync(recursive: true);
      }
    } catch (e) {
      print(e);
    }
  }

  static writeDBToFile() async {
    final time = DateUtil.getNowDateStr();
    final albumList = await DBLogic.to.albumDao.findAllAlbums();
    var buffer = StringBuffer();
    var musicCount = 0;
    for (var album in albumList) {
      buffer.write("    专辑: ${album.albumId} - ${album.albumName}\n");
      final musicList = await DBLogic.to.findAllMusicsByAlbumId(album.albumId!);
      for (var music in musicList) {
        musicCount++;
        buffer.write("        歌曲: ${music.musicId} - ${music.musicName}\n");
      }
    }
    buffer.write("专辑数目: ${albumList.length}; 歌曲数目: $musicCount\n");
    final filePath = "${path}log${Platform.pathSeparator}$time.txt";
    touchFile(filePath);
    File(filePath).writeAsStringSync(buffer.toString(), flush: true);
  }
}
