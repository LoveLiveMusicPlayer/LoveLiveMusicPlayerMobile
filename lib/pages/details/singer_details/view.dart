import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_body.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

class SingerDetailsPage extends StatefulWidget {
  const SingerDetailsPage({Key? key}) : super(key: key);

  @override
  State<SingerDetailsPage> createState() => _SingerDetailsPageState();
}

class _SingerDetailsPageState extends State<SingerDetailsPage> {
  final Artist artist = NestedController.to.artist;
  final music = <Music>[];
  late Widget buildCover;
  late Widget bottom;

  @override
  void initState() {
    buildCover = _buildCover();
    bottom = renderBottom();
    super.initState();
    DBLogic.to.findAllMusicsByArtistBin(artist.uid).then((musicList) {
      music.addAll(musicList);
      DetailController.to.state.items = music;
      setState(() {});
    });
    AppUtils.uploadEvent("SingerDetailsPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            DetailsHeader(title: artist.name),
            SizedBox(height: 8.h),
            GetBuilder<DetailController>(builder: (logic) {
              return DetailsBody(
                logic: logic,
                buildCover: buildCover,
                music: music,
                // onRemove: (music) =>
                //     Log4f.d(msg: "remove: ${music.musicName}"),
              );
            }),
            bottom
          ],
        ));
  }

  Widget _buildCover() {
    return Container(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
              tag: "singer${artist.uid}",
              child: showImg(artist.photo, 240, 240, radius: 120))
        ],
      ),
    );
  }

  Widget renderBottom() {
    if (Platform.isIOS) {
      return Container(height: 24.h);
    } else {
      return Container();
    }
  }
}
