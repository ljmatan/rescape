import 'package:flutter/material.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/ui/screens/scanner/current_order/current_order_entry.dart';

class CurrentOrderList extends StatelessWidget {
  final LocationModel location;
  final List<OrderItemModel> orderItems;

  CurrentOrderList({@required this.location, @required this.orderItems});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location.companyName +
                          (location.number == '0' ? '' : ' ${location.number}'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (var orderItem in orderItems) CurrentOrderEntry(item: orderItem),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
