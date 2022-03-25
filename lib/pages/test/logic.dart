import 'dart:io';
import 'package:common_utils/common_utils.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/Music.dart';
import 'state.dart';

class TestLogic extends GetxController {
  final TestState state = TestState();

  var image = "".obs;
  var currentIndex = 0.obs;
  var musicList = <Music>[].obs;
  var currentMusic = Music().obs ;

  var picPath = "";

  Future<void> getFlac() async {
    const filePath = "LoveLive/Cover_1.jpg";
    Directory appDocDir = await getApplicationDocumentsDirectory();
    picPath = appDocDir.path + Platform.pathSeparator + filePath;
    LogUtil.e(picPath);
    image.value = picPath;
  }

  @override
  Future<void> onReady() async {
    await getFlac();
    musicList.add(Music(name: "START!! True dreams", cover: picPath, singer: "Liella!", time: "03:42"));
    musicList.add(Music(name: "START!! True dreams1212121212", cover: picPath, singer: "Liella!", time: "03:42"));
    musicList.add(Music(name: "START!!", cover: picPath, singer: "Liella!", time: "03:42"));

    currentMusic.value = musicList.value[0];
    super.onReady();
  }
}
