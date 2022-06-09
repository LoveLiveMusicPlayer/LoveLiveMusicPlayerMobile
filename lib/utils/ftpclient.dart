import 'dart:io';
import 'package:common_utils/common_utils.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:path_provider/path_provider.dart';

class FtpClient {

  FTPConnect? ftpConnect;

  Future<FtpClient> connect(String ip, {int port = 7788}) async {
    ftpConnect ??= FTPConnect(ip, port: port, user: 'foo', pass: 'bar', debug: false);
    await ftpConnect!.connect();
    return this;
  }

  void listDirectory() {
    ftpConnect?.listDirectoryContentOnlyNames().then((value) {
      for (var dir in value) {
          LogUtil.d(dir);
      }
    });
  }

  Future<bool> makeDir(String dir) async {
    return await ftpConnect?.makeDirectory(dir) ?? false;
  }

  Future<bool> checkDirectory(String folderName) async {
    LogUtil.d(folderName);
    return await ftpConnect?.changeDirectory(folderName) ?? false;
  }

  Future<Directory> getDest() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> download(String res, String dest,
      Function(String, double) callback) async {
    return await ftpConnect!
        .downloadFile(res, File(dest),
        onProgress: (double percent, int received, int fileSize) {
          callback(res, percent);
        });
  }

  Future<bool> shutdown() async {
    return await ftpConnect?.disconnect() ?? false;
  }
}
