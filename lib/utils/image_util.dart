import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/utils/app_utils.dart';

/**
 * @Author: Sky24n
 * @GitHub: https://github.com/Sky24n
 * @Email: sky24no@gmail.com
 * @Description: Image Util.
 * @Date: 2020/03/10
 */

/// Image Util.
class ImageUtil {
  late ImageStreamListener _listener;
  late ImageStream _imageStream;

  /// get image width height，load error throw exception.（unit px）
  /// 获取图片宽高，加载错误会抛出异常.（单位 px）
  /// image
  /// url network
  /// local url , package
  Future<Rect> getImageWH({
    Image? image,
    String? url,
    String? localUrl,
    String? package,
    ImageConfiguration? configuration,
  }) {
    Completer<Rect> completer = Completer<Rect>();
    _listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        _imageStream.removeListener(_listener);
        if (!completer.isCompleted) {
          completer.complete(Rect.fromLTWH(
              0, 0, info.image.width.toDouble(), info.image.height.toDouble()));
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        _imageStream.removeListener(_listener);
        if (!completer.isCompleted) {
          completer.completeError(exception, stackTrace);
        }
      },
    );

    if (image == null &&
        (url == null || url.isEmpty) &&
        (localUrl == null || localUrl.isEmpty)) {
      return Future.value(Rect.zero);
    }
    Image? img = image;
    img ??= (url != null && url.isNotEmpty)
        ? Image.network(url)
        : Image.asset(localUrl!, package: package);
    _imageStream =
        img.image.resolve(configuration ?? const ImageConfiguration());
    _imageStream.addListener(_listener);
    return completer.future;
  }

  Future<Uint8List?> compressAndTryCatch(String path) async {
    Uint8List? result;
    try {
      if (path.startsWith("assets")) {
        result = await FlutterImageCompress.compressAssetImage(path,
            format: CompressFormat.jpeg,
            quality: 20,
            minHeight: 60.h.toInt(),
            minWidth: ScreenUtil().screenWidth.toInt());
      } else {
        result = await FlutterImageCompress.compressWithFile(path,
            format: CompressFormat.jpeg,
            quality: 20,
            minHeight: 60.h.toInt(),
            minWidth: ScreenUtil().screenWidth.toInt());
      }
    } catch (e) {
      Log4f.d(msg: e.toString(), writeFile: true);
    }
    return result;
  }

  ///裁切图片
  ///[image] 图片路径或文件
  ///[width] 宽度
  ///[height] 高度
  ///[aspectRatio] 比例
  ///[androidUiSettings]UI 参数
  ///[iOSUiSettings] ios的ui 参数
  static Future<CroppedFile?> cropImage(
      {required image,
      required width,
      required height,
      aspectRatio,
      androidUiSettings,
      iOSUiSettings}) async {
    String imagePth = "";
    if (image is String) {
      imagePth = image;
    } else if (image is File) {
      imagePth = image.path;
    } else {
      Log4f.d(msg: 'file_path_error'.tr);
      return null;
    }
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePth,
      maxWidth: AppUtils.num2int(width),
      maxHeight: AppUtils.num2int(height),
      compressQuality: 100,
      aspectRatio: aspectRatio ??
          CropAspectRatio(
              ratioX: AppUtils.num2double(width),
              ratioY: AppUtils.num2double(height)),
      uiSettings: [
        androidUiSettings ??
            AndroidUiSettings(
                toolbarTitle: 'crop_background_image'.tr,
                toolbarColor: Get.theme.primaryColor,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                hideBottomControls: false,
                lockAspectRatio: true),
        iOSUiSettings ??
            IOSUiSettings(
              title: 'crop_background_image'.tr,
            ),
      ],
    );
    return croppedFile;
  }
}
