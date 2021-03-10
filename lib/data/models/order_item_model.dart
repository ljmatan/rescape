import 'package:rescape/data/models/product_model.dart';

class OrderItemModel {
  ProductModel product;
  double measure;

  OrderItemModel({this.product, this.measure});
}
