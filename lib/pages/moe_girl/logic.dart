import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';

class MoeGirlLogic extends GetxController {
  static const adUrlFilters = [
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

  static const strDeleteDom = """
    var divElements = document.querySelectorAll("*");
    // 广告标签关键词
    var keywords = ["广告", "推广", "谷歌广告", "加载中"];
    for (var parent of divElements) {
      // 删除父节点class名为adsbygoogle的
      if (parent.className === 'adsbygoogle') {
        // 移除匹配标签的父节点
        parent.remove();
      }
      var childNodes = parent.childNodes;
      // 判断父节点中子节点个数小于等于3
      if (childNodes.length <= 3) {
        for (var node of childNodes) {
          var elementText = node.textContent;
          // 检查文本内容是否符合广告标签条件
          if (keywords.includes(elementText)) {
            // 移除匹配标签的父节点
            parent.remove();
            break;
          }
        }
      }
    }
  """;

  Timer? deleteADTimer;

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings webViewSettings = InAppWebViewSettings();
  URLRequest urlRequest = URLRequest();

  var showLayout = true.obs;

  int lastY = -1;

  @override
  void onInit() {
    List<ContentBlocker> contentBlockers = [];
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

    webViewSettings.contentBlockers = contentBlockers;
    urlRequest.url = WebUri(Const.moeGirlUrl + Get.arguments);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    deleteADTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      webViewController?.evaluateJavascript(source: strDeleteDom);
    });
  }

  scrollWebView(int y) {
    if (y > 0) {
      if (y > lastY && showLayout.value) {
        showLayout.value = false;
      } else if (!showLayout.value) {
        final isOnTop = y < 30;
        if ((isOnTop && y < lastY) || (lastY - y > 15)) {
          showLayout.value = true;
        }
      }
    }
    lastY = y;
  }

  @override
  void onClose() {
    deleteADTimer?.cancel();
    super.onClose();
  }
}
