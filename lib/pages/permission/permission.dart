import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class Permission extends StatelessWidget {
  const Permission({Key? key}) : super(key: key);

  final message = """尊敬的用户：

请务必认真阅读和理解《软件许可使用协议》（以下简称：本协议）中规定的所有权利和限制，除非您接受协议条款，否则您无权使用本软件及其相关服务。您一旦使用本软件，将视为对协议的接受。

1.权利声明
本软件为开源项目，由作者zhushenwudi权利所有。
其中部分信息内容从网络资源获取，包含但不限于：文字表述及其组合、图标、图像、色彩、有关数据，若因版权问题产生任何矛盾和纠纷，请联系作者本人邮箱55681140@163.com予以删除或替换。
若对软件的宣传、相关文件的转载请联系作者本人进行授权。使用中出现的任何问题均可联系作者获取支持。作者保留为用户提供本软件的修改、升级版本的权利。

2.许可范围
下载、安装和使用：用户可以非商业性、无限制数量的下载、安装及使用本软件。
复制、分发和传播：用户可以非商业性、无限制数量的复制、分发和传播本软件产品，但必须保证每一份复制、分发和传播都是完整和真实的，包括所有有关本软件的软件、电子文档、版权和商标，亦包括协议。

3.隐私安全
本软件不含有除上报崩溃信息、上传本软件内使用数据外的任何旨在破坏用户终端数据和获取用户隐私信息的恶意代码。
不含有任何跟踪、监视用户终端行为的功能代码，不会监控用户网上、网下的行为，不会收集用户使用其他软件、文档等个人信息，不会泄露用户隐私。
收集到的数据将用户分析崩溃中的错误信息用于更好的完善本软件。

4.用户须知
本软件为LoveLive!圈内用户自发使用，不包含任何版权歌曲在内。版权歌曲均由用户本人自行从CD提取导入，导入目录结构详见Github项目文档。
用户应在遵守法律及协议的前提下使用本软件，用户无权实施包括但不限于下列行为：
Ⅰ.不得删除或改变本软件上的所有权利管理电子信息；
Ⅱ.不得利用本软件误导、欺骗他人；
Ⅲ.违反国家规定，对计算机信息系统功能进行删除、修改、增加、干扰，造成计算机信息系统不能正常运行；
Ⅳ.未经允许，进入计算机信息网络或者使用计算机信息网络资源；
Ⅴ.未经允许，对计算机信息网络功能进行删除、修改或者增加的。
""";

  @override
  Widget build(BuildContext context) {
    final uri =
        Uri.parse("https://github.com/zhushenwudi/LoveLiveMusicPlayerMobile");
    final textColor =
        Get.isDarkMode ? TextStyleMs.white_12 : TextStyleMs.black_12;
    return Scaffold(
        backgroundColor: Get.theme.primaryColor,
        appBar: AppBar(
          title: const Text('用户协议及隐私政策'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            child: Column(
              children: [
                Text(message, style: textColor),
                Center(
                  child: Text.rich(TextSpan(
                    text: "本软件开源项目链接",
                    style: TextStyleMs.blue_12,
                    // 设置点击事件
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.inAppWebView);
                        }
                      },
                  )),
                )
              ],
            ),
          ),
        ));
  }
}
