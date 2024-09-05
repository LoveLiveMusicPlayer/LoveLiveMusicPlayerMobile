import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' as get_x;
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/utils/log.dart';
import 'package:lovelivemusicplayer/widgets/one_button_dialog.dart';
import 'package:synchronized/synchronized.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

class Network {
  static Network? _httpRequest;
  static Dio? dio;
  static final Lock _lock = Lock();

  Map<String, dynamic> httpHeaders = {
    'Accept': 'application/json,*/*',
    "Session-Access-Origin": "xxx",
    "Content-Type": "application/json",
    "Cache-Control": "no-cache"
  };

  Network._();

  static Network getInstance() {
    if (_httpRequest == null) {
      _lock.synchronized(() {
        if (_httpRequest == null) {
          var singleton = Network._();
          singleton._init();
          _httpRequest = singleton;
        }
      });
    }
    return _httpRequest!;
  }

  _init() {
    if (dio == null) {
      BaseOptions options = BaseOptions(
          baseUrl: Const.dataOssUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: httpHeaders);
      dio = Dio(options);
      if (kDebugMode) {
        dio?.interceptors.add(TalkerDioLogger(
            settings: TalkerDioLoggerSettings(
                requestFilter: (RequestOptions options) =>
                    !options.path.endsWith('.lrc'),
                responseFilter: (response) =>
                    !response.realUri.path.endsWith(".lrc"),
                errorFilter: (DioException ex) =>
                    ex.response?.statusCode != 404)));
      }
    }
  }

  static getSync(String url,
      {bool isShowDialog = false,
      bool isShowError = false,
      String? loadingMessage}) async {
    if (isShowDialog) {
      SmartDialog.showLoading(msg: loadingMessage ?? 'requesting'.tr);
    }
    var resp = await dio!.get(url).onError((error, stackTrace) {
      _handlerError(
          url, isShowDialog, isShowError, error.toString(), (msg) => null);
      return Future.error("");
    });
    if (isShowDialog) {
      SmartDialog.dismiss(status: SmartStatus.loading);
    }
    return resp.data;
  }

  static get(String url, Function(dynamic t)? success,
      {Map<String, dynamic>? params,
      Function(String msg)? error,
      bool isShowDialog = true,
      bool isShowError = true,
      String? loadingMessage}) {
    request(url,
        method: 'get',
        params: params,
        success: success,
        error: error,
        isShowDialog: isShowDialog,
        isShowError: isShowError,
        loadingMessage: loadingMessage);
  }

  static postSync(String url, dynamic data,
      {bool isShowDialog = false,
      bool isShowError = false,
      String? loadingMessage}) async {
    if (isShowDialog) {
      SmartDialog.showLoading(msg: loadingMessage ?? 'requesting'.tr);
    }
    var resp = await dio!.post(url, data: data).onError((error, stackTrace) {
      _handlerError(
          url, isShowDialog, isShowError, error.toString(), (msg) => null);
      return Future.error("");
    });
    if (isShowDialog) {
      SmartDialog.dismiss(status: SmartStatus.loading);
    }
    return resp.data;
  }

  static post(String url,
      {Map<String, dynamic>? params,
      dynamic data,
      Function(dynamic t)? success,
      Function(String msg)? error,
      bool isShowDialog = true,
      bool isShowError = true,
      String? loadingMessage}) {
    request(url,
        method: 'post',
        params: params,
        data: data,
        success: success,
        error: error,
        isShowDialog: isShowDialog,
        isShowError: isShowError,
        loadingMessage: loadingMessage);
  }

  static Future<Response>? download(String url, String dest,
      ProgressCallback? onReceiveProgress, CancelToken? cancelToken) {
    return dio?.download(url, dest,
        onReceiveProgress: onReceiveProgress, cancelToken: cancelToken);
  }

  static request(String url,
      {String method = 'get',
      Map<String, dynamic>? params,
      dynamic data,
      Function(dynamic t)? success,
      Function(String msg)? error,
      bool isShowDialog = true,
      bool isShowError = true,
      String? loadingMessage}) async {
    if (dio == null) {
      return throw "请先在实例化网络";
    }
    checkNetwork()
        .then((value) => {
              if (value)
                {
                  _dioRequest(
                      url,
                      method,
                      params,
                      data,
                      success,
                      error,
                      isShowDialog,
                      isShowError,
                      loadingMessage ?? 'requesting'.tr)
                }
              else
                {_noNetwork(error, isShowError)}
            })
        .onError((e, stackTrace) => {_noNetwork(error, isShowError)});
  }

  static _dioRequest(
      String url,
      String method,
      Map<String, dynamic>? params,
      dynamic data,
      Function(dynamic t)? success,
      Function(String msg)? error,
      bool isShowDialog,
      bool isShowError,
      String loadingMessage) {
    if (isShowDialog) {
      SmartDialog.showLoading(msg: loadingMessage);
    }
    dio!
        .request<dynamic>(url,
            queryParameters: params,
            data: data,
            options: Options(method: method))
        .then((value) {
      if (success != null) {
        if (isShowDialog) {
          SmartDialog.dismiss(status: SmartStatus.loading);
        }
        success(value.data);
      }
    }).onError((e, stackTrace) =>
            _handlerError(url, isShowDialog, isShowError, e.toString(), error));
  }

  static _noNetwork(Function(String msg)? error, bool isShowError) {
    error?.call('please_check_network'.tr);
    if (isShowError) {
      SmartDialog.show(builder: (context) {
        return OneButtonDialog(
          title: 'please_check_network'.tr,
          isShowMsg: false,
        );
      });
    }
  }

  static _handlerError(String url, bool isShowDialog, bool isShowError,
      String msg, Function(String msg)? error) {
    if (isShowDialog) {
      SmartDialog.dismiss(status: SmartStatus.loading);
    }
    Log4f.d(msg: Uri.decodeFull(url));
    Log4f.d(msg: msg);
    if (isShowError) {
      SmartDialog.show(builder: (context) {
        return OneButtonDialog(
          title: "net_error".tr,
          isShowMsg: false,
        );
      });
    }
    error?.call(msg);
  }

  ///检查网络
  static Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }
}
