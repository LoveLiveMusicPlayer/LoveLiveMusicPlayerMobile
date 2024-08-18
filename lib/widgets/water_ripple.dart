import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/utils/color_manager.dart';
import 'package:lovelivemusicplayer/utils/log.dart';

class WaterRipple extends StatefulWidget {
  const WaterRipple({super.key});

  @override
  State<WaterRipple> createState() => WaterRippleState();
}

class WaterRippleState extends State<WaterRipple>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //动画控制器
  final List<AnimationController> controllers = [];

  //动画控件集合
  final List<Widget> children = [];

  //添加动画计时器
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startAnimation();
    //添加应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 343.r,
        width: 343.r,
        child: Stack(
          alignment: Alignment.center,
          children: children,
        ));
  }

  startAnimation() {
    //动画启动前确保_children控件总数为0
    children.clear();
    int count = 0;
    //添加第一个圆形缩放动画
    addSearchAnimation(true);
    //以后每隔1秒，再次添加一个缩放动画，总共添加4个
    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      addSearchAnimation(true);
      count++;
      if (count >= 4) {
        timer.cancel();
      }
    });
  }

  ///init: 首次添加5个基本控件时，=true，
  void addSearchAnimation(bool init) {
    var controller = createController();
    controllers.add(controller);
    var animation = Tween(begin: 50.0, end: 290.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    if (!init) {
      //5个基本动画控件初始化完成的情况下，每次添加新的动画控件时，移除第一个，确保动画控件始终保持5个
      if (children.isNotEmpty) {
        children.removeAt(0);
      }
      //添加新的动画控件
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        //动画页面没有执行退出情况下，继续添加动画
        children.add(AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                opacity: 1.0 - ((animation.value - 50.0) / 240.0),
                child: ClipOval(
                  child: Container(
                    width: animation.value,
                    height: animation.value,
                    color: ColorMs.colorF940A7,
                  ),
                ),
              );
            }));
        try {
          //动画页退出时，捕获可能发生的异常
          controller.forward();
          setState(() {});
        } catch (e) {
          Log4f.i(msg: e.toString());
          return;
        }
      });
    } else {
      children.add(AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: 1.0 - ((animation.value - 50.0) / 240.0),
              child: ClipOval(
                child: Container(
                  width: animation.value,
                  height: animation.value,
                  color: ColorMs.colorF940A7,
                ),
              ),
            );
          }));
      controller.forward();
      setState(() {});
    }
  }

  ///创建动画控制器
  AnimationController createController() {
    var controller = AnimationController(
        duration: const Duration(milliseconds: 4000), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        if (controllers.contains(controller)) {
          controllers.remove(controller);
        }
        //每次动画控件结束时，添加新的控件，保持动画的持续性
        if (mounted) addSearchAnimation(false);
      }
    });
    return controller;
  }

  ///销毁动画
  void disposeSearchAnimation() {
    //释放动画所有controller
    for (var element in controllers) {
      element.dispose();
    }
    controllers.clear();
    timer?.cancel();
    children.clear();
  }

  ///监听应用状态，
  /// 生命周期变化时回调
  /// resumed:应用可见并可响应用户操作
  /// inactive:用户可见，但不可响应用户操作
  /// paused:已经暂停了，用户不可见、不可操作
  /// suspending：应用被挂起，此状态IOS永远不会回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      //应用退至后台，销毁动画
      disposeSearchAnimation();
    } else if (state == AppLifecycleState.resumed) {
      //应用回到前台，重新启动动画
      startAnimation();
    }
  }

  @override
  void dispose() {
    //销毁动画
    disposeSearchAnimation();
    //销毁应用生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
