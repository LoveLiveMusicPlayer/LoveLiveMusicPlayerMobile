import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/music_Item.dart';
import '../../widgets/refresher_widget.dart';
import 'logic.dart';
import 'widget/listview_item.dart';
import 'widget/song_library_top.dart';

class Song_libraryPage extends StatelessWidget {
  final logic = Get.put(Song_libraryLogic());
  final state = Get.find<Song_libraryLogic>().state;

  Song_libraryPage() {
    LogUtil.d("Song_libraryPage 创建了");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///顶部歌曲总数栏
        Song_libraryTop(
          onPlayTap: () {},
          onScreenTap: () {
            logic.openSelect();
          },
          onSelectAllTap: (checked) {
            logic.selectAll(checked);
          },
          onCancelTap: () {
            logic.openSelect();
          },
        ),

        ///列表数据
        _buildList(),
      ],
    );
  }

  Widget _buildList() {
    return GetBuilder<Song_libraryLogic>(builder: (logic) {
      return Expanded(
        child: RefresherWidget(
          itemCount: logic.state.items.length,
          enablePullDown: logic.state.items.isNotEmpty,
          listItem: (cxt, index) {
            return ListViewItem(
              index: index,
              onItemTap: (valut) {},
              onPlayTap: () {},
              onMoreTap: () {},
            );
          },
          onRefresh: (controller) async {
            await Future.delayed(const Duration(milliseconds: 1000));
            logic.state.items.clear();

            logic.addItem([
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false)
            ]);
            controller.refreshCompleted();
            controller.loadComplete();
          },
          onLoading: (controller) async {
            await Future.delayed(const Duration(milliseconds: 1000));
            logic.addItem([
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false),
              MusicItem(titlle: "", checked: false)
            ]);
            controller.loadComplete();
          },
        ),
      );
    });
  }
}
