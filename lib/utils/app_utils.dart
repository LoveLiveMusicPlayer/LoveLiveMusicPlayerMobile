import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

class AppUtils {

  /// 异步获取歌单封面
  static Future<String> getMusicCoverPath(String? musicPath) async {
    final defaultPath = SDUtils.getImgPath();
    if (musicPath == null) {
      return defaultPath;
    }
    final music = await DBLogic.to.findMusicById(musicPath);
    if (music == null) {
      return defaultPath;
    }
    return SDUtils.path + music.coverPath!;
  }
}