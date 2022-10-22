import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
      CachedNetworkImage.evictFromCache(imageUrl);
    }
    if (imageUrl == null) {
      return null;
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.topCenter,
          fit: BoxFit.fitWidth,
          image: CachedNetworkImageProvider(imageUrl),
        ),
      ),
      child: Container(),
    );
  }

  static Future<bool> checkUrlExist(url) async {
    try {
      await DefaultCacheManager().getSingleFile(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}
