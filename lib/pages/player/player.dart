import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Music.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_info.dart';
import 'package:lovelivemusicplayer/pages/test/logic.dart';
import '../../modules/ext.dart';

class Player extends StatefulWidget {
  final Function onTap;
  final double avoidBottomHeight;

  Player({required this.onTap, required this.avoidBottomHeight});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {

  var logic = Get.find<TestLogic>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: <Widget>[
            coverBg(),
            Column(
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().screenHeight - widget.avoidBottomHeight,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      /// 头部
                      PlayerHeader(onTap: widget.onTap),
                      /// 封面
                      Obx(() => getCover(logic.musicList.value, logic.currentIndex.value)),
                      /// 信息
                      PlayerInfo(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: Column(
                    children: <Widget>[
                      SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 3,
                          thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          inactiveColor: Colors.white.withOpacity(0.1),
                          activeColor: Colors.white,
                          value: 0.5,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (double value) {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "00:35",
                              style: textTheme.bodyText2!.apply(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            Text(
                              "-02:05",
                              style: textTheme.bodyText2!.apply(
                                  color: Colors.white.withOpacity(0.7)),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onPressed: () {},
                              icon: Icon(
                                Icons.repeat,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            IconButton(
                              iconSize: 32,
                              onPressed: () {},
                              icon: const Icon(Icons.skip_previous,
                                  color: Colors.white),
                            ),
                            MaterialButton(
                              onPressed: () {},
                              color: Colors.white,
                              textColor: const Color(0xFF0B1220),
                              child: const Icon(Icons.pause, size: 32),
                              padding: const EdgeInsets.all(16),
                              shape: const CircleBorder(),
                              elevation: 0.0,
                            ),
                            IconButton(
                              iconSize: 32,
                              onPressed: () {},
                              icon:
                              const Icon(Icons.skip_next, color: Colors.white),
                            ),
                            IconButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onPressed: () {},
                              icon: Icon(
                                Icons.shuffle,
                                color: Colors.white.withOpacity(
                                    0.4), //Theme.of(context).accentColor.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getCover(List<Music> musicList, int index) {
    if (musicList.isEmpty) {
      return showImg("assets/thumb/XVztg3oXmX4.jpg", radius: 50, width: 300.w, height: 300.h);
    }
    return showImg(logic.musicList[logic.currentIndex.value].cover,
        radius: 50, width: 300.w, height: 300.h);
  }
}