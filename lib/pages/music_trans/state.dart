import 'package:concurrent_queue/concurrent_queue.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/ftp_music.dart';

class MusicTransState {
  // 当前传输的歌曲
  Rx<DownloadMusic?> currentMusic = Rx<DownloadMusic?>(null);

  // 待下载的歌曲列表
  late RxList<DownloadMusic> musicList;

  late ConcurrentQueue queue;

  late bool isRunning;

  // 可取消的网络请求token
  CancelToken? cancelToken;

  // 下载文件的进度
  late RxInt currentProgress;
  // 当前传输的索引
  late int index;
  // 是否准备开始传输任务
  late RxBool isStartDownload;

  late String? ipAddress;
  late String port;

  MusicTransState() {
    musicList = <DownloadMusic>[].obs;
    queue = ConcurrentQueue(concurrency: 1);
    isRunning = false;
    cancelToken = null;
    currentProgress = 0.obs;
    index = 0;
    isStartDownload = false.obs;

    port = "4388";
  }
}
