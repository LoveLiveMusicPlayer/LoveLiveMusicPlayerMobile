import 'package:lovelivemusicplayer/main.dart';

class Const {
  // 设计图宽度 dp
  static const double uiWidth = 375;

  // 设计图高度 dp
  static const double uiHeight = 812;

  static const String groupAll = "all";
  static const String groupUs = "μ's";
  static const String groupAqours = "Aqours";
  static const String groupSaki = "Nijigasaki";
  static const String groupLiella = "Liella!";
  static const String groupCombine = "Combine";
  static const String groupHasunosora = "Hasunosora";
  static const String groupYohane = "Yohane";

  // Logan 加密键值对
  static const String aesKey = "0123456789012345";
  static const String iV = "0123456789012345";

  static const String bonus = "64198531396358024272298e";

  // 暂无歌曲时使用炫彩模式要显示的颜色值
  static const int noMusicColorfulSkin = 0x4DFFAE00;

  /// sp
  static const String spAllowPermission = "SP_ALLOW_PERMISSION";
  static const String spDark = "SP_IS_DARK";
  static const String spColorful = "SP_IS_COLORFUL";
  static const String spWithSystemTheme = "SP_With_System_Theme";
  static const String spAIPicture = "SP_AI_PICTURE";
  static const String spLoopMode = "SP_LOOP_MODE";
  static const String spDataVersion = "SP_DATA_VERSION";
  static const String spBackgroundPhoto = "SP_BACKGROUND_PHOTO";
  static const String spForceRemoveVersion = "SP_FORCE_REMOVE_VERSION";
  static const String spEnableBackgroundPhoto = "SP_ENABLE_BACKGROUND_PHOTO";
  static const String spEnableHttp = "SP_ENABLE_HTTP";
  static const String spHttpUrl = "SP_HTTP_URL";
  static const String spPrevPage = "prevPage";

  static const String appstoreUrl =
      "https://itunes.apple.com/lookup?bundleId=com.zhushenwudi.lovelivemusicplayer";

  // 默认的资源oss，无法在线获取时用于离线加载网络图片
  static String dataOssUrl = "https://picbed-cdn.zhushenwudi.top/llmp-oss/";

  static String splashUrl = "${dataOssUrl}LLMP-M/splash_bg/";

  static const String lyricOssUrl =
      "https://llmp-oss.oss-cn-hongkong.aliyuncs.com/";

  /// 根服务OSS
  static const String ownOssUrl =
      "https://zhushenwudi1.oss-cn-hangzhou.aliyuncs.com/LLMP-M/data/v2/";

  // 开屏图配置文件
  static const String splashConfigUrl = "${ownOssUrl}splash_config.json";

  // 数据更新文件
  static const String dataUrl = "$ownOssUrl$env/data.json";

  // 歌手文件
  static const String artistModelUrl = "$ownOssUrl$env/artist.json";

  // 版本更新文件
  static const String updateUrl = "$ownOssUrl$env/version.json";

  // 默认LOGO
  static const String shareDefaultLogo =
      "https://zhushenwudi1.oss-cn-hangzhou.aliyuncs.com/LLMP-M/ic_launcher.png";

  // 获取网易云歌曲封面图
  static const String backendUrl =
      "https://netease-backend.zhushenwudi.top/song/detail";

  // 阿里Serverless 分享KV
  static const String shareKvUrl =
      "http://fc-mp-92601a5b-3adb-44ca-b6f6-fc4e8b3edbca.next.bspapp.com/saveShareKV";

  // 萌娘百科主页
  static const String moeGirlUrl = "https://zh.moegirl.org.cn/";

  // SentryDSN
  static const String sentryUrl =
      "https://f93c602d2cca26365680f566db360ce7@o1185358.ingest.sentry.io/4506376468365312";
}
