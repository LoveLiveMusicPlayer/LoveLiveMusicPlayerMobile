import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '/models/ApiResponse.dart';
import '/widgets/one_button_dialog.dart';
import 'package:synchronized/extension.dart';
import './api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Network {
  static Network? _httpRequest;
  static Dio? dio;
  static final Lock _lock = Lock();

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
          baseUrl: ApiService.baseUrl, connectTimeout: ApiService.timeout);
      dio = Dio(options);
      _addInterceptor(dio);
    }
  }

  static get(String url,
      {Map<String, dynamic>? params,
      Function(dynamic t)? success,
      Function(String msg)? error,
      bool isShowDialog = true,
      bool isShowError = true,
      String loadingMessage = "请求网络中..."}) {
    request(url,
        method: 'get',
        params: params,
        success: success,
        error: error,
        isShowDialog: isShowDialog,
        isShowError: isShowError);
  }

  static post(String url,
      {Map<String, dynamic>? params,
      Function(dynamic t)? success,
      Function(String msg)? error,
      bool isShowDialog = true,
      bool isShowError = true,
      String loadingMessage = "请求网络中..."}) {
    request(url,
        method: 'post',
        params: params,
        success: success,
        error: error,
        isShowDialog: isShowDialog,
        isShowError: isShowError);
  }

  static request(String url,
      {String method = 'get',
      Map<String, dynamic>? params,
      Function(dynamic t)? success,
      Function(String msg)? error,
      bool isShowDialog = true,
      bool isShowError = true,
      String loadingMessage = "请求网络中..."}) async {
    // if (SmartDialog.config.isLoading) SmartDialog.dismiss();
    if (dio == null) {
      return throw "请先在实例化网络";
    }
    checkNetwork()
        .then((value) => {
              if (value)
                {
                  _dioRequest(url, method, params, success, error, isShowDialog,
                      isShowError, loadingMessage)
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
      Function(dynamic t)? success,
      Function(String msg)? error,
      bool isShowDialog,
      bool isShowError,
      String loadingMessage) {
    if (isShowDialog) {
      SmartDialog.showLoading(msg: loadingMessage);
    }
    dio!
        .request<Map<String, dynamic>>(url,
            queryParameters: params, options: Options(method: method))
        .then((value) => {_handlerSuccess(value.data, success)})
        .onError((e, stackTrace) =>
            {_handlerError(isShowError, e.toString(), error)});
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
        LogUtil.v(options.path);
      } else {
        LogUtil.v(options.baseUrl + options.path);
      }
      LogUtil.v(options.headers);
      LogUtil.v(options.queryParameters);
      LogUtil.d("拦截了请求");
      handler.next(options);
    }, onResponse: (Response e, ResponseInterceptorHandler handler) {
      LogUtil.v(e.data);
      handler.next(e);
    });
    dio?.interceptors.add(inter);
  }

  static _noNetwork(Function(String msg)? error, bool isShowError) {
    if (error != null) error("请检查网络");
    if (isShowError) {
      SmartDialog.show(
          widget: OneButtonDialog(
        title: "请检查网络",
        isShowMsg: false,
      ));
    }
  }

  static _handlerSuccess(dynamic t, Function(dynamic t)? success) {
    SmartDialog.dismiss();
    if (success != null) {
      success(ApiResponse().fromJson(t).data);
    }
  }

  static _handlerError(
      bool isShowError, String msg, Function(String msg)? error) {
    SmartDialog.dismiss();
    if (isShowError) {
      SmartDialog.show(
          widget: OneButtonDialog(
        title: msg,
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