import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_body.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/widgets/details_cover.dart';

class AlbumDetailsPage extends StatefulWidget {
  const AlbumDetailsPage({Key? key}) : super(key: key);

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  final Album album = NestedController.to.album;
  final music = <Music>[];
  final logic = Get.put(DetailController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      music.addAll(await DBLogic.to.findAllMusicsByAlbumId(album.albumId!));
      logic.state.items = music;
      setState(() {});
    });
    AppUtils.uploadEvent("AlbumDetailsPage");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailController>(builder: (logic) {
      return Scaffold(
          backgroundColor: Get.theme.primaryColor,
          body: Column(children: [
            DetailsHeader(title: 'album_info'.tr),
            SizedBox(height: 8.h),
            DetailsBody(
              logic: logic,
              isAlbum: true,
              buildCover: DetailsCover(album: album),
              music: music,
              // onRemove: (music) =>
              //     Log4f.d(msg: "remove: ${music.musicName}"),
            ),
            renderBottom()
          ]));
    });
  }

  Widget renderBottom() {
    if (Platform.isIOS) {
      return Container(height: 24.h);
    } else {
      return Container();
    }
  }
}
