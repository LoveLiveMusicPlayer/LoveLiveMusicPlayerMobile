import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/ftp_cmd.dart';
import 'package:lovelivemusicplayer/models/ftp_music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/routes.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/another_page_view/another_transformer_page_view.dart';
import 'package:lovelivemusicplayer/widgets/circle_widget.dart';
import 'package:lovelivemusicplayer/widgets/horizontal_line.dart';
import 'package:lovelivemusicplayer/widgets/websocket_widget.dart';

import 'logic.dart';

class MusicTransPage extends StatefulWidget {
  const MusicTransPage({super.key});

  @override
  State<MusicTransPage> createState() => _MusicTransPageState();
}

class _MusicTransPageState extends WebSocketState<MusicTransPage> {
  final logic = Get.put(MusicTransLogic());
  final state = Get.find<MusicTransLogic>().state;

  // banner控制器，无作用，但是必须加，代码控制时也需要这个
  final controller = TransformerPageController();

  @override
  String get title => 'music_trans'.tr;

  @override
  List<Widget> body() {
    return [
      Visibility(visible: isConnected, child: renderTransView()),
      Visibility(visible: !isConnected, child: renderNoTransView())
    ];
  }

  Widget renderTransView() {
    return Obx(() {
      return Column(
        children: [
          SizedBox(height: 35.h),
          drawBody(),
          SizedBox(height: 20.h),
          drawMusicInfo(),
          SizedBox(height: 40.h),
          drawProgressBar()
        ],
      );
    });
  }

  Widget renderNoTransView() {
    return Column(
      children: [
        SizedBox(height: 15.h),
        Visibility(
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            visible: !isConnected,
            child: Center(
                child: SvgPicture.asset(Assets.syncIconDataSync,
                    width: 300.r, height: 300.r))),
        SizedBox(height: 65.h),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(Assets.drawerDrawerSecret,
              width: 15.r, height: 15.r),
          SizedBox(width: 10.r),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300.w),
            child: Text('keep_same_lan'.tr, style: TextStyleMs.gray_12),
          )
        ]),
        SizedBox(height: 4.h),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(Assets.drawerDrawerSecret,
              width: 15.r, height: 15.r),
          SizedBox(width: 10.r),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300.w),
            child:
                Text('keep_screen_and_scan_qr'.tr, style: TextStyleMs.gray_12),
          )
        ]),
        SizedBox(height: 85.h),
        Visibility(
            visible: !isConnected,
            child: btnFunc(Assets.syncIconScanQr, 'device_pair'.tr, () async {
              state.ipAddress = await Get.toNamed(Routes.routeScan) as String?;
              if (state.ipAddress != null) {
                openWebsocket(state.ipAddress!, state.port);
              }
            }))
      ],
    );
  }

  Widget drawMusicInfo() {
    if (state.currentMusic.value == null) {
      return SizedBox(height: 60.h);
    } else {
      return SizedBox(
        height: 60.h,
        child: Column(
          children: [
            Text(state.currentMusic.value!.musicName,
                style: Get.isDarkMode
                    ? TextStyleMs.white_15
                    : TextStyleMs.black_15,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(state.currentMusic.value!.artist,
                style: TextStyleMs.gray_12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }
  }

  Widget drawBody() {
    if (state.index <= 0 || state.musicList.length < state.index) {
      return Container(
          width: 300.h,
          height: 300.h,
          color: Get.theme.primaryColor,
          child: const Image(image: AssetImage(Assets.logoLogo)));
    } else {
      return SizedBox(
        width: 300.h,
        height: 300.h,
        child: TransformerPageView(
          index: state.index - 1,
          viewportFraction: 0.8,
          pageController: controller,
          transformer: ScaleAndFadeTransformer(),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final mCoverPath = state.musicList[index].baseUrl +
                state.musicList[index].coverPath;
            return showImg(SDUtils.getImgPath(fileName: mCoverPath), 400, 400,
                hasShadow: false);
          },
          itemCount: state.musicList.length,
        ),
      );
    }
  }

  Widget drawProgressBar() {
    int current = state.index;
    int total = state.musicList.length;
    double percent = current / total * 100;
    return Stack(
      children: [
        /// 里圈
        SizedBox(
          width: 190.h,
          height: 190.h,
          child: Center(
            child: CustomPaint(
              size: Size(160.h, 160.h),
              painter: CircleView(
                completePercent:
                    state.isStartDownload.value ? percent.roundToDouble() : 0,
                completeColor: ColorMs.colorF940A7,
                lineColors: [ColorMs.colorF940A7],
                completeWidth: 8.w,
                width: 1.w,
                isDividerRound: true,
                lineColor: ColorMs.colorF940A7,
              ),
            ),
          ),
        ),

        /// 外圈
        CustomPaint(
          size: Size(190.h, 190.h),
          painter: CircleView(
            completePercent: 100,
            completeColor: ColorMs.colorF940A7.withAlpha(26),
            lineColors: [],
            completeWidth: 8.w,
          ),
        ),

        /// 中间文字
        drawInnerText(current, total)
      ],
    );
  }

  Widget drawInnerText(int current, int total) {
    if (state.isStartDownload.value) {
      return SizedBox(
        width: 190.h,
        height: 190.h,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("$current",
                style: Get.isDarkMode
                    ? TextStyleMs.white_15
                    : TextStyleMs.black_15),
            SizedBox(height: 15.h),
            HorizontalLine(
                dashedHeight: 1.h,
                dashedWidth: 70.w,
                color: ColorMs.colorCCDDF1),
            SizedBox(height: 15.h),
            Text("$total",
                style: Get.isDarkMode
                    ? TextStyleMs.white_15
                    : TextStyleMs.black_15)
          ],
        )),
      );
    } else {
      return SizedBox(
          width: 190.h,
          height: 190.h,
          child: Center(
              child: Text('data_parsing'.tr,
                  style: Get.isDarkMode
                      ? TextStyleMs.white_15
                      : TextStyleMs.black_15)));
    }
  }

  @override
  Future<void> onHandleMsg(msg) async {
    final ftpCmd = ftpCmdFromJson(msg);
    switch (ftpCmd.cmd) {
      case "version":
        if ((int.tryParse(ftpCmd.body) ?? 0) != GlobalLogic.to.transVer) {
          SmartDialog.showToast("version_incompatible".tr);
          Get.back();
          return;
        }
        addMsgToChannel(FtpCmd(
            cmd: "system", body: Platform.isAndroid ? "android" : "ios"));
        break;
      case "port":
        state.port = ftpCmd.body;
        break;
      case "prepare":
        FtpCmd? cmd = await logic.handlePrepareMsg(ftpCmd);
        if (cmd != null) {
          addMsgToChannel(cmd);
        }
        break;
      case "ready":
        final downloadList = downloadMusicFromJson(ftpCmd.body);
        state.musicList.addAll(downloadList);
        state.isRunning = true;
        break;
      case "download":
        for (var i = 0; i < state.musicList.length; i++) {
          final music = state.musicList[i];
          if (ftpCmd.body.contains(" === ")) {
            final array = ftpCmd.body.split(" === ");
            final musicUId = array[0];
            final isLast = array[1] == "true" ? true : false;
            if (music.musicUId == musicUId) {
              logic.genFileList(music).forEach((map) {
                final url = map["url"] ?? "";
                final isMusic = url.contains(".flac") || url.contains(".wav");
                logic.pushQueue(
                    music,
                    url,
                    map["dest"] ?? "",
                    isMusic,
                    (!isMusic) ? false : isLast,
                    (ftpCmd) => addMsgToChannel(ftpCmd));
              });
            }
          } else {
            addMsgToChannel(FtpCmd(cmd: "download fail", body: music.musicUId));
            Get.back();
          }
        }
        break;
      case "stop":
      case "back":
        release();
        break;
    }
  }

  @override
  void releaseAppend() {
    if (state.queue.size > 0) {
      state.queue.pause();
      state.queue.clear();
    }
    state.cancelToken?.cancel();
  }

  @override
  void dispose() {
    Get.delete<MusicTransLogic>();
    super.dispose();
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double _scale;
  final double _fade;

  ScaleAndFadeTransformer({double fade = 0.3, double scale = 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = info.position!;
    final scaleFactor = (1 - position.abs()) * (1 - _scale);
    final fadeFactor = (1 - position.abs()) * (1 - _fade);
    final opacity = _fade + fadeFactor;
    final scale = _scale + scaleFactor;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}
