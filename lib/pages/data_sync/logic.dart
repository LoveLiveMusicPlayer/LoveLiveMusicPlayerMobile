import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/love.dart';
import 'package:lovelivemusicplayer/models/menu.dart';
import 'package:lovelivemusicplayer/models/trans_data.dart';

import 'state.dart';

class DataSyncLogic extends GetxController {
  final DataSyncState state = DataSyncState();

  void setSwitchValue(bool value) {
    state.switchValue = value;
  }

  void setTransferring(bool value) {
    state.isTransferring = value;
  }

  Future<TransData> getPhone2PcData() async {
    // 传输我喜欢列表 + 手机歌单列表
    return await DBLogic.to
        .getTransPhoneData(needMenuList: true, isCover: state.switchValue);
  }

  Future<TransData> getPc2PhoneData() async {
    // 传输我喜欢列表
    return await DBLogic.to.getTransPhoneData(isCover: state.switchValue);
  }

  replaceLoveList(TransData data) async {
    await DBLogic.to.loveDao.deleteAllLoves();
    await Future.forEach<Love>(data.love, (love) async {
      await DBLogic.to.loveDao.insertLove(love);
    });
  }

  replacePcMenuList(TransData data) async {
    final menuList = data.menu;
    if (data.isCover) {
      await DBLogic.to.menuDao.deleteAllMenus();
    } else {
      await DBLogic.to.menuDao.deletePcMenu();
    }
    await Future.forEach<TransMenu>(menuList, (menu) async {
      final musicList = <String>[];
      await Future.forEach<String>(menu.musicList, (musicUId) async {
        final music = await DBLogic.to.musicDao.findMusicByUId(musicUId);
        if (music != null) {
          musicList.add(musicUId);
        }
      });
      if (musicList.isNotEmpty) {
        await DBLogic.to.menuDao.insertMenu(Menu(
            id: menu.menuId,
            date: menu.date,
            name: menu.name,
            music: musicList));
      }
    });
  }
}
