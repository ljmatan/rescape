import 'dart:async';

abstract class HighlightedAreaController {
  static int _current;
  static int get current => _current;

  static StreamController _streamController;

  static void init() => _streamController = StreamController.broadcast();

  static Stream get stream => _streamController.stream;

  static void change(value) {
    _streamController.add(value);
    _current = value;
  }

  static void dispose() {
    _streamController.close();
    _current = null;
  }
}
