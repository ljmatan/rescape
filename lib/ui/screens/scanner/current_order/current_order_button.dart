import 'package:flutter/material.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/ui/screens/scanner/current_order/current_order_list.dart';

class OrderedItemsButton extends StatelessWidget {
  final Function scanning;
  final LocationModel location;
  final List<OrderItemModel> orderItems;

  OrderedItemsButton({
    @required this.scanning,
    @required this.location,
    @required this.orderItems,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.receipt_long,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () async {
        scanning(false, true);
        await showDialog(
          context: context,
          barrierColor: Colors.white,
          builder: (context) => CurrentOrderList(
            location: location,
            orderItems: orderItems,
          ),
        );
        scanning(true, false);
      },
    );
  }
}
