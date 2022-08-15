import 'package:common_utils/common_utils.dart';
import 'package:flutter/services.dart';

class AndroidBackDesktop {
  //设置回退到手机桌面事件
  static const String eventBackDesktop = "backDesktop";

  //设置回退到手机桌面方法
  static Future<bool> backToDesktop() async {
    //通讯名称，回到手机桌面
    const platform = MethodChannel("android/back/desktop");
    //通知安卓返回到手机桌面
    try {
      await platform.invokeMethod(eventBackDesktop);
      LogUtil.d("通信成功");
    } on PlatformException catch (e) {
      LogUtil.e("通信失败，设置回退到安卓手机桌面失败");
      LogUtil.e(e.toString());
    }
    return Future.value(false);
  }
}
