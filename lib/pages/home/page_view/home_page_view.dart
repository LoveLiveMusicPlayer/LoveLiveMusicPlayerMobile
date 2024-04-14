import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/main.dart';
import 'package:lovelivemusicplayer/models/music.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/modules/pageview/view.dart';
import 'package:lovelivemusicplayer/modules/tabbar/tabbar.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_add_song_sheet.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/pages/home/widget/song_library_top.dart';
import 'package:lovelivemusicplayer/utils/sp_util.dart';
import 'package:lovelivemusicplayer/widgets/two_button_dialog.dart';

class HomePageView extends GetView<HomeController> {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(child: _getTabBarView(() {
      if (HomeController.to.state.selectMode.value == 0) {
        GlobalLogic.to.globalKey.currentState?.openEndDrawer();
      }
    }));
  }

  Widget _getTabBarView(GestureTapCallback? onTap) {
    return Column(
      children: [
        AppBar(
          toolbarHeight: 60.h,
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _getTabBar(),
          systemOverlayStyle: GlobalLogic.to.isDarkTheme.value
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          actions: [_getTopHead(onTap)],
        ),
        _buildListTop(),
        const Expanded(child: PageViewComponent())
      ],
    );
  }

  Widget _getTabBar() {
    return Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: Obx(() {
          return HomeController.to.state.selectMode.value > 0
              ? const IgnorePointer(
                  child: TabBarComponent(),
                )
              : const TabBarComponent();
        }));
  }

  ///顶部头像
  Widget _getTopHead(GestureTapCallback? onTap) {
    return Obx(() {
      final photoPath =
          GlobalLogic.to.getCurrentGroupIcon(GlobalLogic.to.currentGroup.value);
      final color = photoPath == Assets.logoLogo
          ? const Color(Const.noMusicColorfulSkin)
          : Get.theme.primaryColor;
      return logoIcon(photoPath,
          offset: EdgeInsets.only(right: 16.w),
          color: color,
          onTap: onTap,
          hasShadow: GlobalLogic.to.bgPhoto.value == "");
    });
  }

  ///顶部歌曲总数栏
  Widget _buildListTop() {
    return SongLibraryTop(
      onPlayTap: () {
        PlayerLogic.to.playMusic(GlobalLogic.to
            .filterMusicListByIndex(controller.state.currentIndex.value));
      },
      onScreenTap: () {
        controller.openSelect();
        showSelectDialog();
      },
      onSelectAllTap: (checked) {
        controller.selectAll(checked);
      },
      onCancelTap: () {
        SmartDialog.dismiss();
      },
      onSearchTap: (str) {
        controller.filterItem(str);
      },
      onSortTap: () {
        final saveValue = sortMode.value == "ASC" ? "DESC" : "ASC";
        sortMode.value = saveValue;
        SpUtil.put(Const.spSortOrder, saveValue);
        controller.sortItem();
      },
    );
  }

  showSelectDialog() {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList2,
        title: 'add_to_playlist'.tr,
        onTap: () async {
          List<Music> musicList = controller.state.items.cast();
          var isHasChosen =
              controller.state.items.any((element) => element.checked == true);
          if (!isHasChosen) {
            return;
          }
          List<Music> tempList = [];
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              tempList.add(music);
            }
          });
          final isSuccess = await PlayerLogic.to.addMusicList(tempList);
          if (isSuccess) {
            SmartDialog.showToast('add_success'.tr);
          }
          SmartDialog.dismiss();
        }));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList,
        title: 'add_to_menu'.tr,
        onTap: () async {
          List<Music> musicList = controller.state.items.cast();
          var isHasChosen =
              controller.state.items.any((element) => element.checked == true);
          if (!isHasChosen) {
            return;
          }
          List<Music> tempList = [];
          await Future.forEach<Music>(musicList, (music) {
            if (music.checked) {
              tempList.add(music);
            }
          });
          SmartDialog.show(
              alignment: Alignment.bottomCenter,
              builder: (context) {
                return DialogAddSongSheet(
                    musicList: tempList,
                    changeLoveStatusCallback: (status) {
                      SmartDialog.dismiss();
                    },
                    changeMenuStateCallback: (status) {
                      SmartDialog.dismiss();
                    });
              });
        }));
    if (HomeController.to.state.currentIndex.value == 3) {
      // 仅在我喜欢中添加此按钮
      list.add(BtnItem(
          imgPath: Assets.dialogIcDelete2,
          title: "cancel_i_like".tr,
          onTap: () async {
            List<Music> musicList = controller.state.items.cast();
            var isHasChosen = controller.state.items
                .any((element) => element.checked == true);
            if (!isHasChosen) {
              return;
            }
            List<Music> tempList = [];
            await Future.forEach<Music>(musicList, (music) {
              if (music.checked) {
                tempList.add(music);
              }
            });
            SmartDialog.show(builder: (context) {
              return TwoButtonDialog(
                  title: "confirm_to_delete_music".tr,
                  isShowMsg: false,
                  onConfirmListener: () {
                    bool notAllLove =
                        tempList.any((music) => music.isLove == false);
                    PlayerLogic.to.toggleLoveList(tempList, notAllLove);
                    SmartDialog.dismiss();
                  });
            });
          }));
    }
    SmartDialog.show(
        usePenetrate: true,
        clickMaskDismiss: false,
        maskColor: Colors.transparent,
        alignment: Alignment.bottomCenter,
        onDismiss: controller.closeSelect,
        builder: (context) {
          return DialogBottomBtn(
            list: list,
          );
        });
  }
}
