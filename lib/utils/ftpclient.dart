import 'dart:developer';
import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:path_provider/path_provider.dart';

class FtpClient {
  late FTPConnect ftpConnect;

  Future connect(String ip, int port) async {
    ftpConnect = FTPConnect(ip, port: port, user: 'foo', pass: 'bar');
    return await ftpConnect.connect();
  }

  void listDirectory() {
    ftpConnect.listDirectoryContentOnlyNames().then((value) => {
          value.forEach((element) {
            LogUtil.d(element);
          })
        });
  }

  Future checkDirectory(String folderName) async {
    log(folderName);
    return await ftpConnect.changeDirectory(folderName);
  }

  Future getDest() async {
    return await getApplicationDocumentsDirectory();
  }

  Future download(
      String fileName, String dest, Function(String, double) callback) async {
    return await ftpConnect
        .downloadFileWithRetry(fileName, File('$dest/$fileName'),
            onProgress: (double percent, int received, int fileSize) {
      callback(fileName, percent);
    });
  }

  Future shutdown() async {
    return await ftpConnect.disconnect();
  }
}
