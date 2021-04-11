import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/ui/screens/scanner/bloc/last_scanned_controller.dart';

abstract class NewOrder {
  static List<OrderItemModel> _instance = [];
  static List<OrderItemModel> get instance => _instance;

  static void add(OrderItemModel value, [bool newOrder = false]) {
    final OrderItemModel thisItem = _instance.singleWhere(
        (e) => e.product.id == value.product.id,
        orElse: () => null);
    if (thisItem == null)
      _instance.add(value);
    else {
      final OrderItemModel updatedItem = OrderItemModel(
          product: value.product,
          measure: double.parse(
              (thisItem.measure + value.measure).toStringAsFixed(3)));
      _instance.removeWhere((e) => e.product.id == value.product.id);
      _instance.add(updatedItem);
    }
    if (!newOrder)
      LastScannedController.change(_instance
          .firstWhere((e) => e.product.barcode == value.product.barcode));
  }

  static void remove(OrderItemModel item) =>
      _instance.removeWhere((e) => e == item);

  static void clear() => _instance.clear();
}
