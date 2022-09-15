import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_body.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';

class SingerDetailsPage extends StatefulWidget {
  const SingerDetailsPage({Key? key}) : super(key: key);

  @override
  State<SingerDetailsPage> createState() => _SingerDetailsPageState();
}

class _SingerDetailsPageState extends State<SingerDetailsPage> {
  final Artist artist = NestedController.to.artist;
  final music = <Music>[];
  final logic = Get.put(DetailController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      music.addAll(await DBLogic.to.findAllMusicsByArtistBin(artist.uid));
      logic.state.items = music;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailController>(builder: (logic) {
      return Scaffold(
          backgroundColor: Get.theme.primaryColor,
          body: Column(
            children: [
              DetailsHeader(title: artist.name),
              SizedBox(height: 8.h),
              DetailsBody(
                logic: logic,
                buildCover: _buildCover(),
                music: music,
                // onRemove: (music) =>
                //     Log4f.d(msg: "remove: ${music.musicName}"),
              ),
              renderBottom()
            ],
          ));
    });
  }

  Widget _buildCover() {
    return Container(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          showImg(artist.photo, 240, 240, radius: 120),
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
