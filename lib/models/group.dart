import 'package:lovelivemusicplayer/global/const.dart';

class Group {
  String name;
  int key;
  String drawable;
  String logo;
  String? carplayName;
  String? carplayDetail;

  Group({
    required this.name,
    required this.key,
    required this.drawable,
    required this.logo,
    this.carplayName,
    this.carplayDetail,
  });
}

extension GroupKeyExtension on GroupKey {
  String getName() {
    return Const.groupList[index].name;
  }

  String getDrawable() {
    return Const.groupList[index].drawable;
  }

  String getLogo() {
    return Const.groupList[index].logo;
  }
}

extension GroupListExtension on List<Group> {
  String getLogo(String currentGroup) {
    for (var group in Const.groupList) {
      if (group.name == currentGroup) {
        return group.logo;
      }
    }
    return Const.groupList[0].logo;
  }

  String getCarplayName(String currentGroup) {
    String name = Const.groupList[Const.groupList.length - 1].carplayName!;
    for (var group in Const.groupList) {
      if (group.name == currentGroup) {
        if (group.carplayName == null) {
          continue;
        } else {
          name = group.carplayName!;
        }
      }
    }
    return name;
  }

  String getCarplayDetail(String currentGroup) {
    String detail = Const.groupList[Const.groupList.length - 1].carplayDetail!;
    for (var group in Const.groupList) {
      if (group.name == currentGroup) {
        if (group.carplayDetail == null) {
          continue;
        } else {
          detail = group.carplayDetail!;
        }
      }
    }
    return detail;
  }
}

enum GroupKey {
  groupAll,
  groupUs,
  groupAqours,
  groupNijigasaki,
  groupLiella,
  groupHasunosora,
  groupYohane,
  groupCombine
}
