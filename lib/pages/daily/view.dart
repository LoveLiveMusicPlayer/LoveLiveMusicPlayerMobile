import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/pages/daily/logic.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

class DailyPage extends GetView<DailyLogic> {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor =
        Get.isDarkMode ? ColorMs.colorNightPrimary : ColorMs.color28B3F7;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 215, 234, 1),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('daily_news'.tr, style: TextStyleMs.white_18),
        backgroundColor: bgColor,
      ),
      body: SingleChildScrollView(
          child: GetBuilder<DailyLogic>(
              id: 1,
              builder: (logic) {
                return Column(
                  children: [
                    SizedBox(height: 6.h),
                    Text("提示：除特别注明外，此页面或章节的时间均以北京时间（UTC+8）为准。",
                        style: TextStyleMs.black_12,
                        textAlign: TextAlign.center),
                    renderRecent(logic.recentList),
                    renderBangumi(logic.bangumiList),
                    renderToday(logic.today),
                  ],
                );
              })),
    );
  }

  Widget renderRecent(List<RecentOrBangumi> recentList) {
    return renderBg(
      EdgeInsets.only(left: 12.w, top: 6.h, right: 12.w, bottom: 6.h),
      const Color.fromRGBO(181, 226, 252, 0.7),
      "recent_trends".tr,
      null,
      recentList,
    );
  }

  Widget renderBangumi(List<RecentOrBangumi> bangumiList) {
    return renderBg(
      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      const Color.fromRGBO(245, 220, 226, 0.7),
      "live_notice".tr,
      null,
      bangumiList,
    );
  }

  Widget renderToday(Today? today) {
    final day = today?.day ??
        "${DateTime.now().month.toString().padLeft(2, '0')}月"
            "${DateTime.now().day.toString().padLeft(2, '0')}日";
    final dataList = today?.content ?? [];
    return renderBg(
        EdgeInsets.only(left: 12.w, top: 6.h, right: 12.w, bottom: 12.h),
        const Color.fromRGBO(238, 179, 238, 0.7),
        "today_in_previous_years".tr,
        Text(day, style: TextStyleMs.colorB2246A_10),
        dataList);
  }

  Widget renderBg(EdgeInsets margin, Color headerColor, String headerText,
      Widget? extraChild, List<RecentOrBangumi> dataList) {
    return Container(
      margin: margin,
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 150.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromRGBO(255, 255, 255, 0.15),
      ),
      child: Container(
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromRGBO(255, 255, 255, 0.55),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                color: headerColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(headerText, style: TextStyleMs.colorB2246A_18),
                  extraChild ?? Container()
                ],
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: dataList.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    child: Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 12.h,
                          color: Color(
                              int.tryParse(dataList[index].color, radix: 16) ??
                                  0xFFFFAB00),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            dataList[index].content,
                            style: const TextStyle(
                              color: Color.fromRGBO(55, 5, 33, 1),
                            ),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
