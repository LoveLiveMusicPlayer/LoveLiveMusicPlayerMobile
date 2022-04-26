import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_cover.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_header.dart';
import 'package:lovelivemusicplayer/pages/player/widget/player_lyric.dart';
import '../../modules/ext.dart';

class Player extends StatefulWidget {
  final GestureTapCallback onTap;
  var isCover = true.obs;

  Player({required this.onTap});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  double percent = 0.0;

  /// slider 正在被滑动
  var isTouch = false.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: <Widget>[
            coverBg(),
            Column(
              children: <Widget>[
                top(),
                bottom(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget top() {
    return SizedBox(
      height: 600.h,
      child: Column(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top + 16.h),

          /// 头部
          PlayerHeader(onTap: widget.onTap),

          /// 中间可切换的界面
          Obx(() => stackBody()),

          SizedBox(height: 30.h),

          /// 功能栏
          Obx(() => funcButton())
        ],
      ),
    );
  }

  Widget bottom() {
    return Column(
      children: <Widget>[
        /// 滑动条
        slider(),

        /// 用时
        progress(),

        SizedBox(height: 24.h),

        /// 播放器控制组件
        playButton(),
      ],
    );
  }

  Widget stackBody() {
    if (widget.isCover.value) {
      return Cover(onTap: () {
        widget.isCover.value = false;
      });
    } else {
      return Lyric(onTap: () {
        widget.isCover.value = true;
      });
    }
  }

  Widget funcButton() {
    if (!widget.isCover.value) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Obx(() {
              var icon;
              switch (PlayerLogic.to.lrcType.value) {
                case 0:
                  icon = Icons.translate;
                  break;
                case 1:
                  icon = Icons.enhance_photo_translate;
                  break;
                case 2:
                  icon = Icons.g_translate;
                  break;
              }
              return materialButton(
                  icon, () => PlayerLogic.to.toggleTranslate(),
                  width: 32,
                  height: 32,
                  radius: 6,
                  iconColor: const Color(0xFF333333),
                  iconSize: 15);
            })
          ]));
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Obx(() {
            return materialButton(
                PlayerLogic.to.playingMusic.value.isLove
                    ? Icons.favorite
                    : "assets/player/play_love.svg",
                () => PlayerLogic.to.toggleLove(),
                width: 32,
                height: 32,
                radius: 6,
                iconColor: Colors.pinkAccent,
                iconSize: 15);
          }),
          materialButton(Icons.add, () => {},
              width: 32,
              height: 32,
              radius: 6,
              iconColor: const Color(0xFF999999),
              iconSize: 20),
        ],
      ),
    );
  }

  Widget slider() {
    return SliderTheme(
      data: const SliderThemeData(
          trackHeight: 4, thumbShape: RoundSliderThumbShape()),
      child: Obx(() {
        final total = PlayerLogic.to.playingTotal.value;
        if (total == 0) {
          return Slider(
            inactiveColor: const Color(0xFFCCDDF1).withOpacity(0.6),
            activeColor: const Color(0xFFCCDDF1).withOpacity(0.6),
            thumbColor: Theme.of(Get.context!).primaryColor,
            value: 0.0,
            min: 0.0,
            max: 100.0,
            onChanged: (double value) {},
          );
        } else {
          final current = PlayerLogic.to.playingPosition.value;
          /// 延时200ms 来避免首次加载 UI 同时再次更新 UI 导致的异常
          Future.delayed(const Duration(milliseconds: 200)).then((e) {
            /// 手滑滑块时，不进行以下更新 UI 操作
            if (!isTouch.value) {
              try {
                _updateSlider(100 * current / total);
              } catch (e) {
                _updateSlider(0.0);
              }
            }
          });
          return Slider(
              inactiveColor: const Color(0xFFCCDDF1).withOpacity(0.6),
              activeColor: const Color(0xFFCCDDF1).withOpacity(0.6),
              thumbColor: Theme.of(Get.context!).primaryColor,
              value: percent,
              min: 0.0,
              max: 100.0,
              onChangeStart: (double value) {
                isTouch.value = true;
                _updateSlider(value);
              },
              onChanged: (double value) {
                _updateSlider(value);
              },
              onChangeEnd: (double value) {
                _updateSlider(value);
                final position = total * value / 100;
                PlayerLogic.to.seekTo(position.toInt());
                Future.delayed(const Duration(milliseconds: 200)).then((e) {
                  /// 延时200ms后再让obx接受播放器消息改变滑块位置，防止滑块位置跳动
                  isTouch.value = false;
                });
              });
        }
      }),
    );
  }

  /// 更新滑块位置
  _updateSlider(double per) {
    if (per >= 0.0 && per <= 100.0) {
      percent = per;
      setState(() {});
    }
  }

  Widget progress() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final total = PlayerLogic.to.playingTotal.value;
        final current = PlayerLogic.to.playingPosition.value;
        final totalMS = DateUtil.formatDate(DateUtil.getDateTimeByMs(total),
            format: "mm:ss");
        final currentMS = DateUtil.formatDate(DateUtil.getDateTimeByMs(current),
            format: "mm:ss");
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              currentMS,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
            ),
            Text(
              totalMS,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
            )
          ],
        );
      }),
    );
  }

  Widget playButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          materialButton("assets/player/play_shuffle.svg",
              () => PlayerLogic.to.changePlayMode(),
              width: 32,
              height: 32,
              radius: 6,
              iconSize: 15,
              iconColor: const Color(0xFF333333)),
          materialButton("assets/player/play_prev.svg",
              () => PlayerLogic.to.changePlayPrevOrNext(-1),
              width: 60, height: 60, radius: 40, iconSize: 16),
          Obx(() {
            return materialButton(
                PlayerLogic.to.isPlaying.value
                    ? "assets/player/play_pause.svg"
                    : "assets/player/play_play.svg",
                () => PlayerLogic.to.togglePlay(),
                width: 80,
                height: 80,
                radius: 40,
                iconSize: 26);
          }),
          materialButton("assets/player/play_next.svg",
              () => PlayerLogic.to.changePlayPrevOrNext(1),
              width: 60, height: 60, radius: 40, iconSize: 16),
          materialButton("assets/player/play_playlist.svg", () => {},
              width: 32,
              height: 32,
              radius: 6,
              iconSize: 15,
              iconColor: const Color(0xFF333333)),
        ],
      ),
    );
  }

  /// 覆盖背景
  Widget coverBg({Color color = const Color(0xFFF2F8FF), double radius = 34}) {
    return Container(
      height: ScreenUtil().screenHeight,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(34)),
      // child: Stack(
      //   children: buildReaderBackground(),
      // ),
    );
  }

// List<Widget> buildReaderBackground() {
//   return [
//     Positioned.fill(
//         child: GetBuilder<MainLogic>(builder: (logic) {
//           return showImg(logic.state.playingMusic.cover);
//         })
//     ),
//     Positioned.fill(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
//         child: Container(
//           color: Colors.black.withOpacity(0.4),
//         ),
//       ),
//     )
//   ];
// }
}
