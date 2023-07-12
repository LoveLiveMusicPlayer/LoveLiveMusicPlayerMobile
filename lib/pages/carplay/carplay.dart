import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:synchronized/synchronized.dart';

class Carplay {
  static Carplay? _singleton;
  static final Lock _lock = Lock();

  static Carplay getInstance() {
    if (_singleton == null) {
      _lock.synchronized(() {
        if (_singleton == null) {
          var singleton = Carplay._();
          singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton!;
  }

  Carplay._();

  CPConnectionStatusTypes connectionStatus = CPConnectionStatusTypes.unknown;
  final FlutterCarplay _flutterCarplay = FlutterCarplay();

  void _init() {
    final List<CPListSection> section1Items = [];
    section1Items.add(CPListSection(
      items: [
        CPListItem(
          text: "点我播放",
          isPlaying: false,
          playbackProgress: 0,
          image: Assets.logoLogo,
          onPress: (complete, self) async {
            print("随机播放");
            await Future.delayed(const Duration(milliseconds: 1000));
            complete();
          },
        ),
      ],
      header: "音乐盲盒",
    ));
    section1Items.add(CPListSection(
      items: [
        CPListItem(
          text: "μ's",
          detailText: "u咩",
          onPress: (complete, self) {
            openListTemplate();
          },
          image: Assets.logoLogoUs,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
        ),
        CPListItem(
          text: "Aqours",
          detailText: "u咩",
          onPress: (complete, self) {
            openListTemplate();
          },
          image: Assets.logoLogoAqours,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
        ),
        CPListItem(
          text: "虹咲学园学园偶像同好会",
          detailText: "u咩",
          onPress: (complete, self) {
            openListTemplate();
          },
          image: Assets.logoLogoNiji,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
        ),
        CPListItem(
          text: "Liella!",
          detailText: "u咩",
          onPress: (complete, self) {
            openListTemplate();
          },
          image: Assets.logoLogoLiella,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
        ),
        CPListItem(
          text: "莲之空女学院",
          detailText: "u咩",
          onPress: (complete, self) {
            openListTemplate();
          },
          image: Assets.logoLogoHasunosora,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
        ),
        CPListItem(
          text: "幻日夜羽",
          detailText: "u咩",
          onPress: (complete, self) {
            openListTemplate();
          },
          image: Assets.logoLogoYohane,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
        ),
        CPListItem(
          text: "其他",
          detailText: "u咩",
          onPress: (complete, self) {
            openListTemplate();
          },
          image: Assets.logoLogoCombine,
          accessoryType: CPListItemAccessoryTypes.disclosureIndicator,
        ),
      ],
      header: "团组列表",
    ));

    // 点击同步播放
    // await FlutterCarplay.showSharedNowPlaying(animated: true);

    final List<CPListSection> section2Items = [];
    section2Items.add(CPListSection(
      items: [
        CPListItem(
          text: "μ's",
          detailText: "Action template that the user can perform on an alert",
          onPress: (complete, self) {
            showAlert();
            complete();
          },
        ),
        CPListItem(
          text: "Aqours",
          detailText: "A template that displays and manages a grid of items",
          onPress: (complete, self) {
            openGridTemplate();
            complete();
          },
        ),
        CPListItem(
          text: "",
          detailText: "A template that displays a modal action sheet",
          onPress: (complete, self) {
            showActionSheet();
            complete();
          },
        ),
        CPListItem(
          text: "List Template",
          detailText: "Displays and manages a list of items",
          onPress: (complete, self) {
            openListTemplate();
            complete();
          },
        ),
        CPListItem(
          text: "Information Template",
          detailText: "Displays a list of items and up to three actions",
          onPress: (complete, self) {
            openInformationTemplate();
            complete();
          },
        ),
        CPListItem(
          text: "Point Of Interest Template",
          detailText: "Displays a Map with points of interest.",
          onPress: (complete, self) {
            openPoiTemplate();
            complete();
          },
        ),
      ],
      header: "团组",
    ));

    FlutterCarplay.setRootTemplate(
      rootTemplate: CPTabBarTemplate(
        templates: [
          CPListTemplate(
            sections: section1Items,
            title: "歌曲",
            systemIcon: "music.note.house",
          ),
          CPListTemplate(
            sections: section2Items,
            title: "专辑",
            systemIcon: "music.note.list",
          ),
          CPListTemplate(
            sections: [],
            title: "我的",
            emptyViewTitleVariants: ["Settings"],
            emptyViewSubtitleVariants: [
              "No settings have been added here yet. You can start adding right away"
            ],
            systemIcon: "person.fill",
          ),
        ],
      ),
      animated: true,
    );

    _flutterCarplay.addListenerOnConnectionChange(onCarplayConnectionChange);
  }

  void onCarplayConnectionChange(CPConnectionStatusTypes status) {
    // Do things when carplay state is connected, background or disconnected
    connectionStatus = status;
  }

  void showAlert() {
    FlutterCarplay.showAlert(
      template: CPAlertTemplate(
        titleVariants: ["Alert Title"],
        actions: [
          CPAlertAction(
            title: "Okay",
            style: CPAlertActionStyles.normal,
            onPress: () {
              FlutterCarplay.popModal(animated: true);
              print("Okay pressed");
            },
          ),
          CPAlertAction(
            title: "Cancel",
            style: CPAlertActionStyles.cancel,
            onPress: () {
              FlutterCarplay.popModal(animated: true);
              print("Cancel pressed");
            },
          ),
          CPAlertAction(
            title: "Remove",
            style: CPAlertActionStyles.destructive,
            onPress: () {
              FlutterCarplay.popModal(animated: true);
              print("Remove pressed");
            },
          ),
        ],
      ),
    );
  }

  void showActionSheet() {
    FlutterCarplay.showActionSheet(
      template: CPActionSheetTemplate(
        title: "Action Sheet Template",
        message: "This is an example message.",
        actions: [
          CPAlertAction(
            title: "Cancel",
            style: CPAlertActionStyles.cancel,
            onPress: () {
              print("Cancel pressed in action sheet");
              FlutterCarplay.popModal(animated: true);
            },
          ),
          CPAlertAction(
            title: "Dismiss",
            style: CPAlertActionStyles.destructive,
            onPress: () {
              print("Dismiss pressed in action sheet");
              FlutterCarplay.popModal(animated: true);
            },
          ),
          CPAlertAction(
            title: "Ok",
            style: CPAlertActionStyles.normal,
            onPress: () {
              print("Ok pressed in action sheet");
              FlutterCarplay.popModal(animated: true);
            },
          ),
        ],
      ),
    );
  }

  void addNewTemplate(CPListTemplate newTemplate) {
    final currentRootTemplate = FlutterCarplay.rootTemplate!;

    currentRootTemplate.templates.add(newTemplate);

    FlutterCarplay.setRootTemplate(
      rootTemplate: currentRootTemplate,
      animated: true,
    );
    _flutterCarplay.forceUpdateRootTemplate();
  }

  void removeLastTemplate() {
    final currentRootTemplate = FlutterCarplay.rootTemplate!;

    currentRootTemplate.templates.remove(currentRootTemplate.templates.last);

    FlutterCarplay.setRootTemplate(
      rootTemplate: currentRootTemplate,
      animated: true,
    );
    _flutterCarplay.forceUpdateRootTemplate();
  }

  void openGridTemplate() {
    FlutterCarplay.push(
      template: CPGridTemplate(
        title: "Grid Template",
        buttons: [
          for (var i = 1; i < 9; i++)
            CPGridButton(
              titleVariants: ["Item $i"],
              // ----- TRADEMARKS RIGHTS INFORMATION BEGIN -----
              // The official Flutter logo is used from the link below.
              // For more information, please visit and read
              // Flutter Brand Guidelines Website: https://flutter.dev/brand
              //
              // FLUTTER AND THE RELATED LOGO ARE TRADEMARKS OF Google LLC.
              // WE ARE NOT ENDORSED BY OR AFFILIATED WITH Google LLC.
              // ----- TRADEMARKS RIGHTS INFORMATION END -----
              image: Assets.logoLogo,
              onPress: () {
                print("Grid Button $i pressed");
              },
            ),
        ],
      ),
      animated: true,
    );
  }

  void openListTemplate() {
    FlutterCarplay.push(
      template: CPListTemplate(
        sections: [
          CPListSection(
            header: "A Section",
            items: [
              CPListItem(text: "Item 1"),
              CPListItem(text: "Item 2"),
              CPListItem(text: "Item 3"),
              CPListItem(text: "Item 4"),
            ],
          ),
          CPListSection(
            header: "B Section",
            items: [
              CPListItem(text: "Item 5"),
              CPListItem(text: "Item 6"),
            ],
          ),
          CPListSection(
            header: "C Section",
            items: [
              CPListItem(text: "Item 7"),
              CPListItem(text: "Item 8"),
            ],
          ),
        ],
        systemIcon: "systemIcon",
        title: "List Template",
        backButton: CPBarButton(
          title: "Back",
          style: CPBarButtonStyles.none,
          onPress: () {
            FlutterCarplay.pop(animated: true);
          },
        ),
      ),
      animated: true,
    );
  }

  void openInformationTemplate() {
    FlutterCarplay.push(
        template: CPInformationTemplate(
            title: "Title",
            layout: CPInformationTemplateLayout.twoColumn,
            actions: [
          CPTextButton(
              title: "Button Title 1",
              onPress: () {
                print("Button 1");
              }),
          CPTextButton(
              title: "Button Title 2",
              onPress: () {
                print("Button 2");
              }),
        ],
            informationItems: [
          CPInformationItem(title: "Item title 1", detail: "detail 1"),
          CPInformationItem(title: "Item title 2", detail: "detail 2"),
        ]));
  }

  void openPoiTemplate() {
    FlutterCarplay.push(
        template: CPPointOfInterestTemplate(title: "Title", poi: [
          CPPointOfInterest(
            latitude: 51.5052,
            longitude: 7.4938,
            title: "Title",
            subtitle: "Subtitle",
            summary: "Summary",
            detailTitle: "DetailTitle",
            detailSubtitle: "detailSubtitle",
            detailSummary: "detailSummary",
            image: Assets.logoLogo,
            primaryButton: CPTextButton(
                title: "Primary",
                onPress: () {
                  print("Primary button pressed");
                }),
            secondaryButton: CPTextButton(
                title: "Secondary",
                onPress: () {
                  print("Secondary button pressed");
                }),
          ),
        ]),
        animated: true);
  }

  void forceReload() {
    _flutterCarplay.forceUpdateRootTemplate();
  }

  void dispose() {
    _flutterCarplay.removeListenerOnConnectionChange();
  }
}
