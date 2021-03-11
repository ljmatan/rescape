import 'package:rescape/data/models/user_model.dart';
import 'package:rescape/logic/cache/prefs.dart';

abstract class UserData {
  static UserModel _instance;
  static UserModel get instance => _instance;

  static void setInstance(UserModel value) => _instance = value;

  static void init() {
    if (Prefs.instance.getBool('authenticated') == true)
      setInstance(UserModel(Prefs.instance.getString('name'),
          Prefs.instance.getString('userType')));
  }

  static bool get isOwner => _instance.userType == 'owner';
  static bool get isManager => _instance.userType == 'manager';
  static bool get isWorker => _instance.userType == 'worker';
}
