import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/routes.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isStartHomePage = false;
  static const frontUrl =
      "https://video-file-upload.oss-cn-hangzhou.aliyuncs.com/LLMP-M/splash_bg/";

  final imageList = [
    "${frontUrl}yohane/bg_yohane_1.png",
    "${frontUrl}maki/bg_maki_1.png",
    "${frontUrl}shizuku/bg_shizuku_1.png",
    "${frontUrl}you/bg_you_1.png",
    "${frontUrl}chisato/bg_chisato_1.png",
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), goToHomePage);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      initialData: initView(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.data == null) {
          return Container();
        }
        return snapshot.data!;
      },
      future: handlePic(),
    );
  }

  Widget initView() {
    return Container();
  }

  Future<Widget> handlePic() async {
    String? imageUrl;
    final connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      await Future.forEach<String>(imageList, (url) async {
        final isExist = await checkUrlExist(url);
        if (imageUrl == null && isExist) {
          imageUrl = url;
        }
      });
    } else {
      if (imageUrl == null) {
        imageList.shuffle();
        imageUrl = imageList[0];
        CachedNetworkImage.evictFromCache(imageUrl);
      }
    }
    if (imageUrl == null) {
      return initView();
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(imageUrl!),
        ),
      ),
      child: Container(),
    );
  }

  Future<bool> checkUrlExist(url) async {
    try {
      await DefaultCacheManager().getSingleFile(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  void goToHomePage() {
    if (!isStartHomePage) {
      isStartHomePage = true;
      Get.offNamed(Routes.routeInitial);
    }
  }
}
