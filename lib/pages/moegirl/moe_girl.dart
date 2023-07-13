import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';

class MoeGirl extends StatefulWidget {
  const MoeGirl({super.key});

  @override
  State<MoeGirl> createState() => _MoeGirlState();
}

class _MoeGirlState extends State<MoeGirl> {
  final GlobalKey webViewKey = GlobalKey();

  final adUrlFilters = [
    ".*.doubleclick.net/.*",
    ".*.ads.pubmatic.com/.*",
    ".*.googlesyndication.com/.*",
    ".*.google-analytics.com/.*",
    ".*.adservice.google.*/.*",
    ".*.adbrite.com/.*",
    ".*.exponential.com/.*",
    ".*.quantserve.com/.*",
    ".*.scorecardresearch.com/.*",
    ".*.zedo.com/.*",
    ".*.adsafeprotected.com/.*",
    ".*.teads.tv/.*",
    ".*.outbrain.com/.*"
  ];

  final strDeleteDom = """
    // 获取具有 class 为 "adsbygoogle" 的节点
    var adsNode = document.querySelector('.adsbygoogle');
    // 检查节点是否存在
    if (adsNode) {
      // 获取父节点
      var parentNode = adsNode.parentNode;
      // 删除父节点
      parentNode.remove();
      console.log("成功删除父节点.");
    } else {
      console.log("未找到具有 class 为 'adsbygoogle' 的节点.");
    }
  """;

  final List<ContentBlocker> contentBlockers = [];
  late Timer _timer;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();

    for (final adUrlFilter in adUrlFilters) {
      contentBlockers.add(ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: adUrlFilter,
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.BLOCK,
          )));
    }

    contentBlockers.add(ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
            type: ContentBlockerActionType.CSS_DISPLAY_NONE,
            selector: ".banner, .banners, .ads, .ad, .advert")));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      webViewController?.evaluateJavascript(source: strDeleteDom);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("萌娘百科"),
          backgroundColor:
              Get.isDarkMode ? ColorMs.colorNightPrimary : ColorMs.color28B3F7,
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                      URLRequest(url: WebUri(Const.moeGirlUrl + Get.arguments)),
                  initialSettings:
                      InAppWebViewSettings(contentBlockers: contentBlockers),
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                  },
                ),
              ],
            ),
          ),
        ])));
  }
}
