import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/details/logic.dart';
import 'package:lovelivemusicplayer/pages/details/menu_details/logic.dart';
import 'package:lovelivemusicplayer/widgets/details_body/view.dart';
import 'package:lovelivemusicplayer/widgets/header.dart';

abstract class DetailsPage<T extends DetailController> extends GetView<T> {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cover = renderCover(); // 防止多次渲染，提前渲染对象
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: [
          AppHeader(title: controller.state.title),
          SizedBox(height: 8.h),
          GetBuilder<T>(builder: (logic) {
            final isMenuPage = logic is MenuDetailController;
            return DetailsBody(
              logic: logic,
              buildCover: cover,
              onRemove: isMenuPage ? logic.onRemoveTap : null,
            );
          })
        ]));
  }

  Widget renderCover();
}
