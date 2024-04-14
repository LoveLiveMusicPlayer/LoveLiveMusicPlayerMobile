import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/album.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_body.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/widgets/details_cover.dart';

class AlbumDetailsPage extends StatefulWidget {
  const AlbumDetailsPage({super.key});

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  final Album album = NestedController.to.album;
  final music = <Music>[];
  late Widget buildCover;
  late Widget bottom;

  @override
  void initState() {
    buildCover = DetailsCover(album: album);
    bottom = renderBottom();
    super.initState();
    DBLogic.to.findAllMusicsByAlbumId(album.albumId!).then((musicList) {
      music.addAll(musicList);
      DetailController.to.state.items = music;
      setState(() {});
    });
    AppUtils.uploadEvent("AlbumDetailsPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: [
          DetailsHeader(title: 'album_info'.tr),
          SizedBox(height: 8.h),
          GetBuilder<DetailController>(builder: (logic) {
            return DetailsBody(
              logic: logic,
              isAlbum: true,
              buildCover: buildCover,
              music: music,
              // onRemove: (music) =>
              //     Log4f.d(msg: "remove: ${music.musicName}"),
            );
          }),
          bottom
        ]));
  }

  Widget renderBottom() {
    if (Platform.isIOS) {
      return Container(height: 24.h);
    } else {
      return Container();
    }
  }
}
