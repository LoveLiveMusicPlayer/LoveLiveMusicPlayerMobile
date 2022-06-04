import 'dart:async';

Function debounceUtil(Function fn, [int t = 300]) {
  Timer? _debounce;
  return () {
    // 还在时间之内，抛弃上一次
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: t), () {
      fn();
    });
  };
}