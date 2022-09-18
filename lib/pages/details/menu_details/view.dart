import 'dart:io';

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
import 'package:lovelivemusicplayer/pages/home/nested_page/nested_controller.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class MenuDetailsPage extends StatefulWidget {
  const MenuDetailsPage({Key? key}) : super(key: key);

  @override
  State<MenuDetailsPage> createState() => _MenuDetailsPageState();
}

class _MenuDetailsPageState extends State<MenuDetailsPage> {
  final music = <Music>[];
  Menu? menu;
  final logic = Get.put(DetailController());

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  refreshData() {
    Future.delayed(Duration.zero, () async {
      menu = await DBLogic.to.menuDao.findMenuById(NestedController.to.menuId);
      final musicList = menu?.music;
      music.clear();
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
          body: Column(children: [
            DetailsHeader(title: menu?.name ?? ""),
            SizedBox(height: 8.h),
            DetailsBody(
                logic: logic,
                buildCover: _buildCover(),
                music: music,
                onRemove: (music) async {
                  if (menu == null || menu!.id == 0) {
                    return;
                  }
                  final status = await DBLogic.to
                      .removeItemFromMenu(menu!.id, [music.musicId!]);
                  switch (status) {
                    case 1:
                      refreshData();
                      break;
                    case 2:
                      Get.back();
                      break;
                    default:
                      break;
                  }
                }),
            renderBottom()
          ]));
    });
  }

  Widget _buildCover() {
    if (menu == null || menu!.music.isEmpty) {
      return showImg(SDUtils.getImgPath(), 240, 240, radius: 120);
    }
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
            future: AppUtils.getMusicCoverPath(menu!.music.last),
          )
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
