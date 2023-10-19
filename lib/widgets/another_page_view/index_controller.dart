import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class IndexController extends ChangeNotifier {
  static const int nextEvent = 1;
  static const int previousEvent = -1;
  static const int moveEvent = 0;

  late Completer _completer;

  int? index;
  late bool animation;
  int? event;

  Future move(int index, {bool animation = true}) {
    this.animation = animation;
    this.index = index;
    event = moveEvent;
    _completer = Completer();
    notifyListeners();
    return _completer.future;
  }

  Future next({bool animation = true}) {
    event = nextEvent;
    this.animation = animation;
    _completer = Completer();
    notifyListeners();
    return _completer.future;
  }

  Future previous({bool animation = true}) {
    event = previousEvent;
    this.animation = animation;
    _completer = Completer();
    notifyListeners();
    return _completer.future;
  }

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}
