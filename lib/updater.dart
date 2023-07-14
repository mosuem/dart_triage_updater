import 'dart:async';

class Updater {
  final StreamController<bool> status = StreamController();
  final StreamController<String?> text = StreamController();

  Updater();

  void open(String message) {
    status.add(true);
    text.add(message);
  }

  void close() => status.add(false);

  void set(String s) => text.add(s);
}
