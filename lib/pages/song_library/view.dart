import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/song_library/widget/song_library_list.dart';

import '../../widgets/refresher_widget.dart';
import 'logic.dart';
import 'widget/listview_item.dart';
import 'widget/song_library_top.dart';

class Song_libraryPage extends StatelessWidget {
  final logic = Get.put(Song_libraryLogic());
  final state = Get.find<Song_libraryLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ///顶部歌曲总数栏
        GetBuilder<Song_libraryLogic>(builder: (logic) {
          return Song_libraryTop(
            state: logic.state,
            onPlayTap: () {},
            onScreenTap: () {
              logic.openSelect();
            },
            onSelectAllTap: (checked) {},
            onCancelTap: () {
              logic.openSelect();
            },
          );
        }),

        _buildList(),
      ],
    );
  }

  Widget _buildList() {
    return Expanded(
      child: GetBuilder<Song_libraryLogic>(
        assignId: true,
        builder: (logic) {
          return RefresherWidget(
            itemCount: logic.state.items.length,
            enablePullDown: logic.state.items.isNotEmpty,
            listItem: (cxt, index) {
              return ListViewItem(
                onItemTap: (valut) {},
                onPlayTap: () {},
                onMoreTap: () {},
              );
            },
            onRefresh: (controller) async {
              await Future.delayed(const Duration(milliseconds: 1000));
              logic.state.items.clear();
              logic.addItem(["xx", "x", "x"]);
              controller.refreshCompleted();
              controller.loadComplete();
            },
            onLoading: (controller) async {
              await Future.delayed(const Duration(milliseconds: 1000));
              logic.addItem(["xx", "x", "x", "x"]);
              controller.loadComplete();
            },
          );
        },
      ),
    );
  }
}
