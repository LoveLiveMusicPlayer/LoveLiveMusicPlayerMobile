import 'dart:async';

class CompleterExt {
  static Future<T> awaitFor<T>(Function(Function(T)) run) {
    var c = Completer<T>();

    run((r) {
      if (c.isCompleted) {
        return;
      }
      c.complete(r);
    });

    return c.future;
  }
}
