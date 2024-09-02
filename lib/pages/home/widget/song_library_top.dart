import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:lovelivemusicplayer/widgets/circular_check_box.dart';

class SongLibraryTop extends GetView<GlobalLogic> {
  final Function onPlayTap;
  final GestureTapCallback onScreenTap;
  final Function(String) onSearchTap;
  final GestureTapCallback onSortTap;
  final Function(bool) onSelectAllTap;
  final Function onCancelTap;

  const SongLibraryTop({
    super.key,
    required this.onPlayTap,
    required this.onScreenTap,
    required this.onSearchTap,
    required this.onSortTap,
    required this.onSelectAllTap,
    required this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return buildTopWidget();
    });
  }

  ///获取顶部显示布局
  Widget buildTopWidget() {
    if (HomeController.to.state.currentIndex.value == 2 ||
        HomeController.to.state.currentIndex.value == 4) {
      return Container();
    }

    if (HomeController.to.state.selectMode.value == 1) {
      return _buildSelectSong();
    } else if (HomeController.to.state.selectMode.value == 2) {
      return _buildSearchSong();
    } else {
      return _buildPlaySong();
    }
  }

  ///播放歌曲条目
  Widget _buildPlaySong() {
    return Container(
      height: 35.h,
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 14.w),
          _buildPlayBtn(),
          SizedBox(width: 10.w),
          _buildSongNumText(),
          _buildSearch(),
          _buildSort(),
          _buildFilter(),
        ],
      ),
    );
  }

  ///播放按钮
  Widget _buildPlayBtn() {
    final hasShadow = GlobalLogic.to.bgPhoto.value == "";
    return GestureDetector(
      onTap: () => onPlayTap(),
      child: Container(
          width: 56.h,
          height: 24.h,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  ColorMs.colorFF86C9,
                  ColorMs.colorF940A7,
                ],
              ),
              borderRadius: BorderRadius.circular(12.h),
              boxShadow: hasShadow
                  ? [
                      BoxShadow(
                          color: GlobalLogic.to.getThemeColor(
                              ColorMs.color05080C, ColorMs.colorD3E0EC),
                          blurRadius: 6,
                          offset: const Offset(5, 3)),
                    ]
                  : []),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 20.h,
          )),
    );
  }

  ///歌曲总数
  Widget _buildSongNumText() {
    final index = HomeController.to.state.currentIndex.value;
    return Expanded(
      child: Obx(() {
        return Text(
            "${controller.getListSize(index, controller.databaseInitOver.value)} ${index == 1 ? 'total_album_number_unit'.tr : 'total_number_unit'.tr}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyleMs.f14_400.copyWith(
                color: (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
                    ? ColorMs.colorFFFFFF
                    : ColorMs.color333333));
      }),
    );
  }

  Widget _buildSearch() {
    if (HomeController.to.state.currentIndex.value == 1) {
      return Container();
    }
    return neumorphicButton(
      Assets.mainIcSearch,
      () {
        HomeController.to.state.selectMode.value = 2;
        HomeController.to.state.oldMusicList = [...controller.musicList];
        HomeController.to.state.oldLoveList = [...controller.loveList];
        HomeController.to.state.oldRecentList = [...controller.recentList];
      },
      width: 30,
      height: 30,
      iconColor: (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
          ? ColorMs.colorFFFFFF
          : ColorMs.colorCCCCCC,
      hasShadow: false,
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
    );
  }

  Widget _buildSort() {
    if (HomeController.to.state.currentIndex.value == 1) {
      return Container();
    }
    return neumorphicButton(
      GlobalLogic.to.sortMode.value == "ASC"
          ? Assets.mainIcSortAsc
          : Assets.mainIcSortDesc,
      onSortTap,
      width: 30,
      height: 30,
      iconColor: (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
          ? ColorMs.colorFFFFFF
          : ColorMs.colorCCCCCC,
      hasShadow: false,
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
    );
  }

  ///筛选按钮
  Widget _buildFilter() {
    if (HomeController.to.state.currentIndex.value == 1) {
      return Container();
    }
    return neumorphicButton(Assets.mainIcFunction, onScreenTap,
        width: 30,
        height: 30,
        iconColor: (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
            ? ColorMs.colorFFFFFF
            : ColorMs.colorCCCCCC,
        hasShadow: false,
        margin: EdgeInsets.only(left: 3.h, top: 3.h, right: 18.w, bottom: 3.h));
  }

  ///播放歌曲条目
  Widget _buildSelectSong() {
    final textStyle = (Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "")
        ? TextStyleMs.f15_400.copyWith(color: Colors.white)
        : TextStyleMs.f15_400.copyWith(color: Colors.black);
    return Container(
      color: Colors.transparent,
      height: 45.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.h,
          ),
          GetBuilder<HomeController>(builder: (logic) {
            return CircularCheckBox(
              checked: HomeController.to.state.selectAll,
              checkIconColor: ColorMs.colorF940A7,
              uncheckedIconColor: ColorMs.colorD6D6D6,
              spacing: 10.h,
              iconSize: 25,
              title:
                  "${'select_items'.tr} ${HomeController.to.getCheckedSong()} ${'total_number_unit'.tr}",
              textStyle: textStyle,
              onChecked: (value) {
                HomeController.to.state.selectAll = value;
                onSelectAllTap(value);
              },
            );
          }),
          Expanded(child: Container()),
          GestureDetector(
            onTap: () => onCancelTap(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.h),
              child: Text(
                'finish'.tr,
                style: textStyle,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchSong() {
    final isDarkTheme = Get.isDarkMode || GlobalLogic.to.bgPhoto.value != "";
    final textStyle = isDarkTheme
        ? TextStyleMs.f15_400.copyWith(color: Colors.white)
        : TextStyleMs.f15_400.copyWith(color: Colors.grey);
    final bgColor = isDarkTheme
        ? const Color.fromRGBO(255, 255, 255, 0.1)
        : const Color.fromRGBO(0, 0, 0, 0.05);

    InputBorder inputBorder() {
      return const OutlineInputBorder(
        borderSide: BorderSide(width: 0, color: Colors.transparent),
      );
    }

    return Container(
      color: Colors.transparent,
      height: 35.h,
      child: Row(
        children: [
          Expanded(
              child: Container(
            height: 35.h,
            margin: EdgeInsets.only(left: 8.w, right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r), color: bgColor),
            child: Row(
              children: [
                Icon(Icons.search,
                    color: isDarkTheme ? Colors.white : Colors.grey),
                SizedBox(width: 8.w),
                Expanded(
                  child: FocusScope(
                    canRequestFocus: true,
                    child: TextField(
                        maxLines: 1,
                        controller: HomeController.to.state.searchControl,
                        autofocus: true,
                        style: const TextStyle(
                            textBaseline: TextBaseline.alphabetic),
                        cursorColor: isDarkTheme ? Colors.white : Colors.grey,
                        decoration: InputDecoration(
                            hintText: 'input_song_main_char'.tr,
                            hintStyle: textStyle,
                            isCollapsed: false,
                            suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                color: isDarkTheme ? Colors.white : Colors.grey,
                                highlightColor: Colors.transparent,
                                onPressed: () {
                                  HomeController.to.state.searchControl.clear();
                                  HomeController.to.filterItem("");
                                }),
                            focusedBorder: inputBorder(),
                            disabledBorder: inputBorder(),
                            errorBorder: inputBorder(),
                            focusedErrorBorder: inputBorder(),
                            enabledBorder: inputBorder(),
                            border: inputBorder(),
                            contentPadding: const EdgeInsets.all(0)),
                        onSubmitted: onSearchTap,
                        textInputAction: TextInputAction.search),
                  ),
                )
              ],
            ),
          )),
          GestureDetector(
            child: Container(
              height: 45.h,
              margin: EdgeInsets.only(left: 4.w, top: 0, right: 8.w, bottom: 0),
              padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 10.r),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: Text('cancel'.tr, style: textStyle),
              ),
            ),
            onTap: () {
              HomeController.to.state.selectMode.value = 0;
              HomeController.to.closeFilter();
            },
          ),
        ],
      ),
    );
  }
}
