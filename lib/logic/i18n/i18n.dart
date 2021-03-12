import 'dart:io' as ui;

import 'package:rescape/logic/cache/prefs.dart';

import 'i18n/../values.dart';

abstract class I18N {
  static String _locale = Prefs.instance.getString('locale') ??
      (ui.Platform.localeName.startsWith('en') ? 'en' : 'sr');

  static String get locale => _locale;

  static void setLocale(String newLocale) {
    _locale = newLocale;
    Prefs.instance.setString('locale', newLocale);
  }

  static String text(String text) => Values.instance[locale][text];
}
