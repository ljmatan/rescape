import 'package:rescape/data/models/product_model.dart';

class OrderItemModel {
  ProductModel product;
  double measure;
  bool forceMeasure;

  OrderItemModel({this.product, this.measure, this.forceMeasure: false});
}
