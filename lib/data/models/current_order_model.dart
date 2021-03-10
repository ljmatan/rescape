import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/order_item_model.dart';

class CurrentOrderModel {
  DateTime time;
  LocationModel location;
  List<OrderItemModel> items;
  String key;

  CurrentOrderModel({this.time, this.location, this.items, this.key});
}
