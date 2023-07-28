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
    // 获取 HTML 中所有元素
    var elements = document.getElementsByTagName("*");
    // 创建一个空数组用于存储元素及其对应的 z-index 层级和 class
    var elementsWithZIndex = [];
    // 遍历所有元素
    for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      // 获取元素的 z-index 层级
      var zIndex = getComputedStyle(element).getPropertyValue("z-index");
      // 获取元素的 class
      var className = element.className;
      // 将元素及其 z-index 层级和 class 存储到数组中
      elementsWithZIndex.push({ element: element, zIndex: zIndex, className: className });
    }
    
    // 根据 z-index 层级进行排序
    elementsWithZIndex.sort(function(a, b) {
      return parseInt(a.zIndex) - parseInt(b.zIndex);
    });
    
    // 输出排序后的 class
    for (var j = elementsWithZIndex.length - 1; j > elementsWithZIndex.length - 15; j--) {
      if (elementsWithZIndex[j].className == "") {
        continue;
      }                                                                                                      
      console.log(elementsWithZIndex[j].className);
      var adsNode = document.querySelector("." + elementsWithZIndex[j].className);
      // 检查节点是否存在
      if (adsNode) {
      	adsNode.remove();
      } else {
        console.log("未找到节点.");
      }
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
          elevation: 0,
          title: Text('moe_girl_wiki'.tr),
          backgroundColor:
              Get.isDarkMode ? ColorMs.colorNightPrimary : ColorMs.color28B3F7,
        ),
        body: Stack(
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
        ));
  }
}
