import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/Menu.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_body.dart';
import 'package:lovelivemusicplayer/pages/details/widget/details_header.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class MenuDetailsPage extends StatefulWidget {
  const MenuDetailsPage({Key? key}) : super(key: key);

  @override
  State<MenuDetailsPage> createState() => _MenuDetailsPageState();
}

class _MenuDetailsPageState extends State<MenuDetailsPage> {
  final Menu menu = Get.arguments;
  final music = <Music>[];
  final logic = Get.put(DetailController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final musicList = menu.music;
      if (musicList != null && musicList.isNotEmpty) {
        music.addAll(await DBLogic.to.musicDao.findMusicsByMusicIds(musicList));
      }
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
            DetailsHeader(title: menu.name),
            DetailsBody(
                logic: logic,
                buildCover: _buildCover(),
                music: music
            )
          ],
        ),
      );
    });
  }

  Widget _buildCover() {
    return Container(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<String>(
            initialData: SDUtils.getImgPath(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return showImg(snapshot.data, 240, 240, radius: 120);
            },
            future: AppUtils.getMusicCoverPath(menu.music?.last),
          )
        ],
      ),
    );
  }
}
