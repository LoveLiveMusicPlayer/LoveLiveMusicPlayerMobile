import 'package:common_utils/common_utils.dart';
import 'package:get/get.dart';
import '/network/http_request.dart';

import 'state.dart';

class MainLogic extends GetxController {
  final MainState state = MainState();

  getData() {
    Network.get('https://inventory.scionedev.ilabservice.cloud/api/labbase/v1/company/all?account=17826808739&type=saas', success: (w) {
      if (w != null && w is List) {
        for (var element in w) {
          LogUtil.e(element);
        }
      }
    });
  }
}
