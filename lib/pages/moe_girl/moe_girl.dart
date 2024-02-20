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

  final List<ContentBlocker> contentBlockers = [];
  Timer? _deleteADTimer;
  Timer? _showLayoutTimer;
  InAppWebViewController? webViewController;
  bool _showLayout = true;

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

    _deleteADTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      webViewController?.evaluateJavascript(source: strDeleteDom);
    });
  }

  @override
  void dispose() {
    webViewController?.dispose();
    _deleteADTimer?.cancel();
    _showLayoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showLayout
          ? AppBar(
              elevation: 0,
              title: Text('moe_girl_wiki'.tr),
              backgroundColor: Get.isDarkMode
                  ? ColorMs.colorNightPrimary
                  : ColorMs.color28B3F7,
            )
          : null,
      body: SafeArea(
        bottom: _showLayout,
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              onScrollChanged: (controller, x, y) {
                if (_showLayoutTimer?.isActive == true) {
                  _showLayoutTimer?.cancel();
                }
                _showLayoutTimer =
                    Timer.periodic(const Duration(seconds: 1), (timer) {
                  if (!_showLayout) {
                    setState(() {
                      _showLayout = true;
                    });
                  }
                });
                setState(() {
                  _showLayout = false;
                });
              },
              initialUrlRequest:
                  URLRequest(url: WebUri(Const.moeGirlUrl + Get.arguments)),
              initialSettings:
                  InAppWebViewSettings(contentBlockers: contentBlockers),
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
            ),
            if (_showLayout)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Get.theme.primaryColor,
                  height: 50,
                  child: Center(
                    child: ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          child: const Icon(Icons.arrow_back),
                          onPressed: () => webViewController?.goBack(),
                        ),
                        MaterialButton(
                          child: const Icon(Icons.arrow_forward),
                          onPressed: () => webViewController?.goForward(),
                        ),
                        MaterialButton(
                          child: const Icon(Icons.refresh),
                          onPressed: () => webViewController?.reload(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
