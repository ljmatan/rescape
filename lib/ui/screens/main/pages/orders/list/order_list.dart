import 'package:flutter/material.dart';
import 'package:rescape/data/current_order.dart';
import 'package:rescape/data/models/current_order_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/list/edit_quantity_dialog.dart';
import 'package:rescape/ui/screens/main/pages/orders/selection_display.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/current_orders/current_orders.dart';
import 'package:rescape/ui/shared/pdf_doc_display.dart';
import 'package:rescape/ui/screens/scanner/camera_screen.dart';

class OrderList extends StatelessWidget {
  final CurrentOrderModel order;
  final bool processed, returns;

  OrderList({
    this.order,
    this.processed: false,
    this.returns: false,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: [
          ListView(
            children: [
              if (UserData.isOwner || UserData.isManager)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(order.vehicle.model + ' ' + order.vehicle.plates),
                      Row(
                        children: [
                          if (UserData.isManager || UserData.isOwner)
                            IconButton(
                              icon: Icon(Icons.list),
                              onPressed: () => showDialog(
                                context: context,
                                barrierColor: Colors.grey.shade200,
                                builder: (context) => PDFDocDisplay(
                                  order: order,
                                  screenWidth:
                                      MediaQuery.of(context).size.width,
                                  processed: processed,
                                  returns: returns,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              order.time.day.toString() +
                                  '.' +
                                  order.time.month.toString() +
                                  '.' +
                                  order.time.year.toString() +
                                  '.',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 16),
              for (var item in order.items)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: StatefulBuilder(
                    builder: (context, newState) => GestureDetector(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          boxShadow: kElevationToShadow[1],
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 56,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(item.product.id.toString()),
                              ),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(item.product.name),
                                ),
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
                      onTap: processed
                          ? () async {
                              showDialog(
                                  context: context,
                                  barrierColor: Colors.white70,
                                  builder: (context) => EditAmountDialog(
                                      item: item, rebuildParent: newState));
                            }
                          : null,
                    ),
                  ),
                ),
              SizedBox(height: processed ? 16 : 88),
            ],
          ),
          if (!processed)
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
                            I18N.text('BACK'),
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
                              I18N.text('PROCESS'),
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
                            builder: (BuildContext context) =>
                                CameraScreen(vehicle: order.vehicle),
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
        OrdersViewController.change(SelectionDisplay());
        return false;
      },
    );
  }
}
