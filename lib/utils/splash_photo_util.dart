import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/eventbus/eventbus.dart';
import 'package:lovelivemusicplayer/eventbus/start_event.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

var background = const BoxDecoration();

class SplashPhoto {
  static const frontUrl =
      "https://video-file-upload.oss-cn-hangzhou.aliyuncs.com/LLMP-M/splash_bg/";

  final imageList = [
    "${frontUrl}yohane/bg_yohane_1.png",
    "${frontUrl}maki/bg_maki_1.png",
    "${frontUrl}shizuku/bg_shizuku_1.png",
    "${frontUrl}you/bg_you_1.png",
    "${frontUrl}chisato/bg_chisato_1.png",
  ];

  Future<Widget?> getRandomPhotoView() async {
    return await handlePic(imageList);
  }

  Future<Widget?> handlePic(List<String> imageList) async {
    if (imageList.isEmpty) {
      return null;
    }
    String? imageUrl;
    final connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      final offlineList = <String>[];
      await Future.forEach<String>(imageList, (url) async {
        final isExist = await checkUrlExist(url);
        if (isExist) {
          offlineList.add(url);
        }
      });
      if (offlineList.isNotEmpty) {
        offlineList.shuffle();
        imageUrl = offlineList[0];
      }
    } else {
      imageList.shuffle();
      imageUrl = imageList[0];
    }
    if (imageUrl == null) {
      return null;
    }
    final image = DecorationImage(
      alignment: Alignment.topCenter,
      fit: BoxFit.fitWidth,
      image: CachedNetworkImageProvider(imageUrl,
          cacheManager: AppUtils.cacheManager),
    );
    final stream = image.image.resolve(const ImageConfiguration());
    stream.addListener(
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      Future.delayed(const Duration(seconds: 1), () {
        eventBus.fire(StartEvent((DateTime.now().millisecondsSinceEpoch)));
      });
    }, onError: (object, stackTrace) {
      Log4f.d(msg: "下载开屏图失败\n$imageUrl");
    }));
    background = BoxDecoration(image: image);
    return Container(
      decoration: background,
      child: Container(),
    );
  }

  static Future<bool> checkUrlExist(url) async {
    try {
      await AppUtils.cacheManager.getSingleFile(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}
