import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scan/scan.dart';

class Scanner extends StatelessWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScanController controller = ScanController();
    return SizedBox(
      width: 250.h,
      height: 250.h,
      child: ScanView(
        controller: controller,
        scanAreaScale: .7,
        scanLineColor: Colors.green.shade400,
        onCapture: (data) {
          Get.back(result: data);
        },
      ),
    );
  }
}
