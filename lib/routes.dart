import 'package:get/get.dart';
import 'pages/test/view.dart';
import 'pages/main/view.dart';

class Routes {
  static const String routeInitial = "/";
  static const String routeTest = "/test";
  static const String routeScan = "/scan";
  static const String routeTransform = "/transform";

  static List<GetPage> getRoutes() {
    return [
      GetPage(name: Routes.routeInitial, page: () => MainPage()),
      GetPage(name: Routes.routeTest, page: () => TestPage()),
    ];
  }
}