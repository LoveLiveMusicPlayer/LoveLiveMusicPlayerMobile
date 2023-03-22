import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' as Getx;
import 'package:log4f/log4f.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/widgets/one_button_dialog.dart';
import 'package:synchronized/extension.dart';

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
          connectTimeout: 30000,
          headers: httpHeaders);
      dio = Dio(options);
      _addInterceptor(dio);
    }
  }

  static getSync(String url,
      {bool isShowDialog = false,
      bool isShowError = false,
      String? loadingMessage}) async {
    if (isShowDialog) {
      SmartDialog.compatible
          .showLoading(msg: loadingMessage ?? 'requesting'.tr);
    }
    var resp = await dio!.get(url).onError((error, stackTrace) {
      if (isShowError) {
        SmartDialog.compatible.show(
            widget: OneButtonDialog(
          title: 'please_check_network'.tr,
          isShowMsg: false,
        ));
      }
      throw Future.error(error.toString());
    });
    if (isShowDialog) {
      SmartDialog.compatible.dismiss();
    }
    return resp.data;
  }

  static get(String url,
      {Map<String, dynamic>? params,
      Function(dynamic t)? success,
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
      SmartDialog.compatible
          .showLoading(msg: loadingMessage ?? 'requesting'.tr);
    }
    var resp = await dio!.post(url, data: data).onError((error, stackTrace) {
      if (isShowError) {
        SmartDialog.compatible.show(
            widget: OneButtonDialog(
          title: 'please_check_network'.tr,
          isShowMsg: false,
        ));
      }
      throw Future.error(error.toString());
    });
    if (isShowDialog) {
      SmartDialog.compatible.dismiss();
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
      SmartDialog.compatible.showLoading(msg: loadingMessage);
    }
    dio!
        .request<dynamic>(url,
            queryParameters: params,
            data: data,
            options: Options(method: method))
        .then((value) {
      if (success != null) success(value.data);
    }).onError(
            (e, stackTrace) => _handlerError(isShowError, e.toString(), error));
  }

  static _addInterceptor(Dio? dio) {
    // 2.添加第一个拦截器
    Interceptor inter = InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      // 1.在进行任何网络请求的时候, 可以添加一个loading显示
      // 2.很多页面的访问必须要求携带Token,那么就可以在这里判断是有Token
      // 3.对参数进行一些处理,比如序列化处理等
      //     options.extra

      if (options.path.startsWith("http") || options.path.startsWith("https")) {
        print(options.path);
      } else {
        print(options.baseUrl + options.path);
      }
      // LogUtil.v(options.headers);
      // LogUtil.v(options.queryParameters);
      // LogUtil.d("拦截了请求");
      handler.next(options);
    }, onResponse: (Response e, ResponseInterceptorHandler handler) {
      print(e.data);
      handler.next(e);
    });
    dio?.interceptors.add(inter);
  }

  static _noNetwork(Function(String msg)? error, bool isShowError) {
    if (error != null) error('please_check_network'.tr);
    if (isShowError) {
      SmartDialog.compatible.show(
          widget: OneButtonDialog(
        title: 'please_check_network'.tr,
        isShowMsg: false,
      ));
    }
  }

  static _handlerError(
      bool isShowError, String msg, Function(String msg)? error) {
    SmartDialog.compatible.dismiss();
    if (isShowError) {
      Log4f.e(msg: msg, writeFile: true);
      SmartDialog.compatible.show(
          widget: OneButtonDialog(
        title: "net_error".tr,
        isShowMsg: false,
      ));
    }
    if (error != null) error(msg);
  }

  ///检查网络
  static Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
