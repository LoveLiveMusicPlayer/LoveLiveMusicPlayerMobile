import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/models/group.dart';

class Const {
  // 设计图宽度 dp
  static const double uiWidth = 375;

  // 设计图高度 dp
  static const double uiHeight = 812;

  static final List<Group> groupList = [
    Group(
        name: "all",
        key: GroupKey.groupAll.index,
        logo: Assets.logoLogo,
        drawable: Assets.drawerLogoLovelive),
    Group(
      name: "μ's",
      key: GroupKey.groupUs.index,
      logo: Assets.logoLogoUs,
      drawable: Assets.drawerLogoUs,
      carplayName: "μ's",
      carplayDetail: "ラブライブ！",
    ),
    Group(
      name: "Aqours",
      key: GroupKey.groupAqours.index,
      drawable: Assets.drawerLogoAqours,
      logo: Assets.logoLogoAqours,
      carplayName: "Aqours",
      carplayDetail: "ラブライブ！サンシャイン!!",
    ),
    Group(
      name: "Nijigasaki",
      key: GroupKey.groupNijigasaki.index,
      drawable: Assets.drawerLogoNijigasaki,
      logo: Assets.logoLogoNiji,
      carplayName: "虹咲学园学园偶像同好会",
      carplayDetail: "虹ヶ咲学園スクールアイドル同好会",
    ),
    Group(
      name: "Liella!",
      key: GroupKey.groupLiella.index,
      drawable: Assets.drawerLogoLiella,
      logo: Assets.logoLogoLiella,
      carplayName: "Liella!",
      carplayDetail: "ラブライブ！スーパースター!!",
    ),
    Group(
      name: "Hasunosora",
      key: GroupKey.groupHasunosora.index,
      drawable: Assets.drawerLogoHasunosora,
      logo: Assets.logoLogoHasunosora,
      carplayName: "莲之空女学院",
      carplayDetail: "蓮ノ空女学院スクールアイドルクラブ",
    ),
    Group(
      name: "Yohane",
      key: GroupKey.groupYohane.index,
      drawable: Get.isDarkMode
          ? Assets.drawerLogoYohaneNight
          : Assets.drawerLogoYohaneDay,
      logo: Assets.logoLogoYohane,
      carplayName: "幻日夜羽",
      carplayDetail: "幻日のヨハネ -SUNSHINE in the MIRROR-",
    ),
    // 最后一个必须是Combine
    Group(
      name: "Combine",
      key: GroupKey.groupCombine.index,
      drawable: Assets.drawerLogoAllstars,
      logo: Assets.logoLogoCombine,
      carplayName: "其他",
      carplayDetail: "u咩",
    ),
  ];

  // Logan 加密键值对
  static const String qqKey = "375f94ab8316c";
  static const String qqSecret = "9cac7a0532d211eb04fcf6b25b197859";

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
  static const String spSortOrder = "SP_SORT_ORDER";
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
  static String dataUrl = "$ownOssUrl${GlobalLogic.to.env}/data.json";

  // 歌手文件
  static String artistModelUrl = "$ownOssUrl${GlobalLogic.to.env}/artist.json";

  // 版本更新文件
  static String updateUrl = "$ownOssUrl${GlobalLogic.to.env}/version.json";

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

  static const String pushUrl =
      "https://zhushenwudi1.oss-cn-hangzhou.aliyuncs.com/LLMP-M/push/push.txt";

  static const String homeWidgetGroupId =
      "group.com.zhushenwudi.lovelivemusicplayer";

  static const String androidReceiverName =
      "com.zhushenwudi.lovelivemusicplayer.home_widget.widget1.HomeWidgetReceiver";
}
