import 'dart:convert';

import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';

class DailyLogic extends GetxController {
  final recentList = <RecentOrBangumi>[];
  final bangumiList = <RecentOrBangumi>[];
  Today? today;

  @override
  void onInit() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) {
      fetchData();
    } else {
      parseArgs(args);
    }
    super.onInit();
  }

  fetchData() {
    Network.get(Const.pushUrl, success: (resp) async {
      parseArgs(jsonDecode(resp));
      update([1]);
    });
  }

  parseArgs(args) {
    for (var r in args["recent"]) {
      final event = RecentOrBangumi(color: r["color"], content: r["content"]);
      recentList.add(event);
    }
    for (var b in args["bangumi"]) {
      final event = RecentOrBangumi(color: b["color"], content: b["content"]);
      bangumiList.add(event);
    }
    final contentList = <RecentOrBangumi>[];
    for (var t in args["today"]["content"]) {
      final event = RecentOrBangumi(color: t["color"], content: t["content"]);
      contentList.add(event);
    }
    today = Today(day: args["today"]["day"], content: contentList);
  }
}

class RecentOrBangumi {
  String color;
  String content;

  RecentOrBangumi({required this.color, required this.content});
}

class Today {
  String day;
  List<RecentOrBangumi> content;

  Today({required this.day, required this.content});
}
