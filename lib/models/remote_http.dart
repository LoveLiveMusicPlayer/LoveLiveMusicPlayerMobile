import 'package:flutter/material.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';

/// HTTP远端曲库实体类
class RemoteHttp {
  late ValueNotifier<bool> enableHttp;
  late ValueNotifier<String> httpUrl;

  RemoteHttp(bool enableHttp, String httpUrl) {
    this.enableHttp = ValueNotifier(enableHttp);
    this.httpUrl = ValueNotifier(httpUrl);
  }

  // 是否开启了远端HTTP服务
  bool isEnableHttp() {
    return enableHttp.value;
  }

  // 是否没有正确填写远端曲库URL
  bool noneHttpUrl() {
    return httpUrl.value.isEmpty || httpUrl.value == '/';
  }

  // 是否能够拼接完整URL路径
  bool canUseHttpUrl() {
    return isEnableHttp() && !noneHttpUrl();
  }

  setEnableHttp(bool newValue) async {
    enableHttp.value = newValue;
    await PlayerLogic.to.removeAllMusics();
    await SpUtil.put(Const.spEnableHttp, newValue);
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
  }

  setHttpUrl(String newValue) async {
    httpUrl.value = newValue;
    await SpUtil.put(Const.spHttpUrl, newValue);
    await DBLogic.to.findAllListByGroup(GlobalLogic.to.currentGroup.value);
  }
}
