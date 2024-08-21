import 'package:concurrent_queue/concurrent_queue.dart';
import 'package:dio/dio.dart';
import 'package:lovelivemusicplayer/models/ftp_music.dart';

class MusicTransState {
  // 当前传输的歌曲
  DownloadMusic? currentMusic;

  // 待下载的歌曲列表
  late List<DownloadMusic> musicList;

  late ConcurrentQueue queue;

  late bool isRunning;

  // 可取消的网络请求token
  CancelToken? cancelToken;

  // 下载文件的进度
  late int currentProgress;
  // 当前传输的索引
  late int index;
  // 是否准备开始传输任务
  late bool isStartDownload;

  late String? ipAddress;
  late String port;

  MusicTransState() {
    currentMusic = null;
    musicList = [];
    queue = ConcurrentQueue(concurrency: 1);
    isRunning = false;
    cancelToken = null;
    currentProgress = 0;
    index = 0;
    isStartDownload = false;

    port = "4388";
  }
}
