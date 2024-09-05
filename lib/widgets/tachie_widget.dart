import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

class Tachie extends StatelessWidget {
  final bool canMove;

  const Tachie({super.key, this.canMove = true});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final musicId = PlayerLogic.to.playingMusic.value.musicId;
      if (musicId == null || !GlobalLogic.to.hasSkin.value) {
        return Container();
      }
      return Padding(
          padding: EdgeInsets.only(
              bottom: GlobalLogic.to.needHomeSafeArea.value ? 90.h : 0),
          child: SizedBox(
            height: 180.h,
            width: double.infinity,
            child: InAppWebView(
              key: ValueKey(musicId),
              initialSettings: InAppWebViewSettings(
                  supportZoom: false,
                  transparentBackground: true,
                  verticalScrollBarEnabled: false,
                  horizontalScrollBarEnabled: false),
              onWebViewCreated: (controller) async {
                final music = await DBLogic.to.findMusicById(musicId);
                if (music == null || music.artistBin == null) {
                  return;
                }
                final map = AppUtils.getArtistIndexArrInGroup(music.artistBin!);

                if (map == null) {
                  return;
                }

                bool isBonus = Const.bonus == musicId;

                final url =
                    "http://localhost:8080/index.html?isBonus=$isBonus&bin=${map["artistBin"]}&group=${map["group"]}&canMove=$canMove";

                controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
              },
            ),
          ));
    });
  }
}
