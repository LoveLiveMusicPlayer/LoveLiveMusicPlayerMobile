import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/details/singer_details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/view.dart';

class SingerDetailsPage extends DetailsPage<SingerDetailController> {
  const SingerDetailsPage({super.key});

  @override
  Widget renderCover() {
    final artist = controller.artist;
    return Hero(
        tag: "singer${artist.uid}",
        child: showImg(artist.photo, 240, 240, isCircle: true));
  }
}
