import 'package:flutter/material.dart';
import 'package:rescape/data/current_order.dart';
import 'package:rescape/data/models/current_order_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/selection_display.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/current_orders/current_orders.dart';
import 'package:rescape/ui/screens/scanner/camera_screen.dart';

class OrderList extends StatelessWidget {
  final CurrentOrderModel order;

  OrderList(this.order);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 16),
              for (var item in order.items)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: kElevationToShadow[1],
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(item.product.name),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                item.product.measureType == Measure.kg
                                    ? '${item.measure}kg'
                                    : '×${item.measure.floor()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 88),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 32,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 48,
                      child: Center(
                        child: Text(
                          'BACK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    onTap: () => OrdersViewController.change(CurrentOrders()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: kElevationToShadow[1],
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        child: Center(
                          child: Text(
                            'PROCESS',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      CurrentOrder.setInstance(order);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => CameraScreen(),
                        ),
                      );
                      OrdersViewController.change(SelectionDisplay());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onWillPop: () async {
        OrdersViewController.change(CurrentOrders());
        return false;
      },
    );
  }
}
