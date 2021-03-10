import 'package:rescape/data/models/current_order_model.dart';

abstract class CurrentOrder {
  static CurrentOrderModel _instance;
  static CurrentOrderModel get instance => _instance;

  static void setInstance(CurrentOrderModel value) => _instance = value;
}
