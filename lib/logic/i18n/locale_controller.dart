import 'dart:async';

import 'package:rescape/logic/i18n/i18n.dart';

abstract class LocaleController {
  static StreamController _streamController;

  static void init() => _streamController = StreamController.broadcast();

  static Stream get stream => _streamController.stream;

  static void change(value) {
    I18N.setLocale(value);
    _streamController.add(value);
  }

  static void dispose() => _streamController.close();
}
