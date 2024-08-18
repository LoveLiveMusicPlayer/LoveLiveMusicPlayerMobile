import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

/// 嵌套导航栈的变化监听
class MyNavigator extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    String? previousName;
    if (previousRoute != null) {
      previousName = previousRoute.settings.name;
    }
    if (NestedController.to.fromGestureBack) {
      NestedController.to.goBack(fromBtnBack: false);
      return;
    }
    if (previousName == Routes.routeHome) {
      Timer(const Duration(milliseconds: 500), () {
        NestedController.to.reduceNav();
      });
    }
    NestedController.to.fromGestureBack = true;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      AppUtils.uploadPageStart(name);
    }
    super.didPush(route, previousRoute);
  }
}
