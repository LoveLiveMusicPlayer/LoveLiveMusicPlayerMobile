import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class Tachie extends StatelessWidget {
  final bool canMove;

  const Tachie({Key? key, this.canMove = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final musicId = PlayerLogic.to.playingMusic.value.musicId;
      if (musicId == null || !GlobalLogic.to.hasSkin.value) {
        return Container();
      }
      return Padding(
          padding: EdgeInsets.only(
              bottom: GlobalLogic.to.needHomeSafeArea.value ? 25.h : 0.h),
          child: SizedBox(
            height: 180.h,
            width: double.infinity,
            child: WebViewPlus(
                key: ValueKey(musicId),
                javascriptMode: JavascriptMode.unrestricted,
                zoomEnabled: false,
                onWebViewCreated: (controller) async {
                  final music = await DBLogic.to.findMusicById(musicId);
                  if (music == null || music.artistBin == null) {
                    return;
                  }
                  final map =
                      AppUtils.getArtistIndexArrInGroup(music.artistBin!);

                  if (map == null) {
                    return;
                  }

                  bool isBonus = Const.bonus == musicId;

                  controller.loadUrl(
                      'assets/tachie/index.html?isBonus=$isBonus&bin=${map["artistBin"]}&group=${map["group"]}&canMove=$canMove');
                },
                backgroundColor: Colors.transparent),
          ));
    });
  }
}
