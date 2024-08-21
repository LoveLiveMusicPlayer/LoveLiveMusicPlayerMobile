import 'package:get/get.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionLogic extends GetxController {
  final uriGithub =
      Uri.parse("https://github.com/zhushenwudi/LoveLiveMusicPlayerMobile");
  final uriUmeng = Uri.parse("https://www.umeng.com/page/policy");
  final uriShare = Uri.parse("https://www.mob.com/about/policy");
  final uri360 = Uri.parse("https://jiagu.360.cn/#/global/help/322");

  @override
  void onInit() {
    super.onInit();
    AppUtils.uploadEvent("Permission");
  }

  launchWeb(Uri url) {
    canLaunchUrl(url).then((canLaunch) {
      if (canLaunch) {
        launchUrl(url, mode: LaunchMode.inAppWebView);
      }
    });
  }
}
