import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/moe_girl/logic.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class MoeGirlPage extends GetView<MoeGirlLogic> {
  const MoeGirlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bgColor =
          Get.isDarkMode ? ColorMs.colorNightPrimary : ColorMs.color28B3F7;
      bool showLayout = controller.showLayout.value;
      return Scaffold(
        appBar: (Platform.isAndroid || showLayout)
            ? AppBar(
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text('moe_girl_wiki'.tr, style: TextStyleMs.white_18),
                backgroundColor: bgColor,
              )
            : null,
        body: Container(
          color: bgColor,
          child: SafeArea(
            bottom: showLayout,
            child: Stack(
              children: [
                InAppWebView(
                    key: controller.webViewKey,
                    onScrollChanged: (_, x, y) => controller.scrollWebView(y),
                    initialUrlRequest: controller.urlRequest,
                    initialSettings: controller.webViewSettings,
                    onLoadStart: (controller, url) =>
                        this.controller.isWebViewLoading.value = true,
                    onLoadResource: (controller, resource) =>
                        this.controller.isWebViewLoading.value = false,
                    onWebViewCreated: (controller) =>
                        this.controller.webViewController = controller),
                if (showLayout) renderBottomBar(bgColor),
                if (controller.isWebViewLoading.value)
                  Center(child: CircularProgressIndicator(color: Colors.green)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget renderBottomBar(Color? color) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: color,
        height: 50,
        child: Center(
          child: OverflowBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                child: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => controller.webViewController?.goBack(),
              ),
              MaterialButton(
                child: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () => controller.webViewController?.goForward(),
              ),
              MaterialButton(
                child: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => controller.webViewController?.reload(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
