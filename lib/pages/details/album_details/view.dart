import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_body.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/widgets/details_cover.dart';

class AlbumDetailsPage extends StatefulWidget {
  const AlbumDetailsPage({Key? key}) : super(key: key);

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  final Album album = Get.arguments;
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
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailController>(builder: (logic) {
      return WillPopScope(
          onWillPop: !logic.state.isSelect
              ? null
              : () async {
                  if (Platform.isIOS) {
                    SmartDialog.dismiss();
                    Get.back();
                  }
                  return true;
                },
          child: Scaffold(
              backgroundColor: Get.theme.primaryColor,
              body: Column(
                children: [
                  DetailsHeader(title: album.albumName!),
                  SizedBox(height: 8.h),
                  DetailsBody(
                      logic: logic,
                      isAlbum: true,
                      buildCover: DetailsCover(album: album),
                      // onRemove: (music) =>
                      //     Log4f.d(msg: "remove: ${music.musicName}"),
                      music: music)
                ],
              )));
    });
  }
}
