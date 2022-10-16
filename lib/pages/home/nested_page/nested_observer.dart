import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/routes.dart';

/// 嵌套导航栈的变化监听
class MyNavigator extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    String? previousName;
    if (previousRoute != null) {
      previousName = previousRoute.settings.name;
    }
    // Log4f.v(msg: "didPop: from ${route.settings.name} to $previousName");
    if (NestedController.to.fromGestureBack) {
      NestedController.to.goBack(fromBtnBack: false);
      return;
    }
    if (previousName == Routes.routeHome) {
      NestedController.to.reduceNav();
    }
    NestedController.to.fromGestureBack = true;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    String? previousName;
    if (previousRoute != null) {
      previousName = previousRoute.settings.name;
    }
    // Log4f.v(msg: "didPush: from $previousName to ${route.settings.name}");
  }
}
