import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/Splash.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/completerExt.dart';

var background = const BoxDecoration();

class SplashPhoto {
  Future<Widget?> getRandomPhotoView() async {
    if (splashList.isEmpty) {
      return null;
    }
    String? imageUrl;
    final connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      final offlineList = <String>[];
      await Future.forEach<String>(splashList, (url) async {
        final isExist = await AppUtils.checkUrlExist(url);
        if (isExist) {
          offlineList.add(url);
        }
      });
      if (offlineList.isNotEmpty) {
        offlineList.shuffle();
        imageUrl = offlineList[0];
      }
    } else {
      splashList.shuffle();
      imageUrl = splashList[0];
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

    return await CompleterExt.awaitFor<Widget?>((run) {
      Widget? widget;
      final stream = image.image.resolve(const ImageConfiguration());
      stream.addListener(
          ImageStreamListener((ImageInfo info, bool synchronousCall) async {
        final splashItem =
            await DBLogic.to.splashDao.findSplashByUrl(imageUrl!);
        if (splashItem == null) {
          await DBLogic.to.splashDao.insertSplashUrl(Splash(url: imageUrl));
        }
        print(imageUrl);
        widget = Container(
          decoration: BoxDecoration(image: image),
          child: Container(),
        );
        run(widget);
      }, onError: (object, stackTrace) {
        Log4f.d(msg: "下载开屏图失败\n$imageUrl");
        run(null);
      }));
    });
  }
}
