import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/song_library/state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/circular_check_box.dart';
import '../../../widgets/refresher_widget.dart';
import '../logic.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'listview_item.dart';

class Song_libraryList extends StatefulWidget {
  Song_libraryState state;
  final Function onRefresh;
  final Function onLoading;

  Song_libraryList({
    Key? key,
    required this.state,
    required this.onRefresh,
    required this.onLoading,
  }) : super(key: key);

  @override
  State<Song_libraryList> createState() => _Song_libraryListState();
}

class _Song_libraryListState extends State<Song_libraryList> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Song_libraryLogic>(
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
            widget.onRefresh();
          },
          onLoading: (controller) async {
            await Future.delayed(const Duration(milliseconds: 1000));
            logic.addItem(["xx", "x", "x", "x"]);
            controller.loadComplete();
            widget.onLoading();
          },
        );
      },
    );
  }
}
