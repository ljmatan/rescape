import 'package:flutter/material.dart';
import 'package:rescape/data/current_order.dart';
import 'package:rescape/ui/screens/scanner/current_order/current_order_list.dart';

class OrderedItemsButton extends StatelessWidget {
  final Function scanning;

  OrderedItemsButton({@required this.scanning});

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
            location: CurrentOrder.instance.location,
            orderItems: CurrentOrder.instance.items,
          ),
        );
        scanning(true, false);
      },
    );
  }
}
