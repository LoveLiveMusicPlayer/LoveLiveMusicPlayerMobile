import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyHttpServer {
  static InAppLocalhostServer? localhostServer;

  static void startServer() {
    localhostServer ??= InAppLocalhostServer(documentRoot: 'assets/tachie');
    if (true == localhostServer?.isRunning()) {
      return;
    }
    localhostServer?.start();
  }

  static void stopServer() {
    if (localhostServer == null) {
      return;
    }
    if (true == localhostServer?.isRunning()) {
      localhostServer?.close();
    }
    localhostServer = null;
  }
}
