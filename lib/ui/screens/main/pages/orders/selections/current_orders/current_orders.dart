import 'package:flutter/material.dart';
import 'package:rescape/data/company_list.dart';
import 'package:rescape/data/models/current_order_model.dart';
import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/data/models/vehicle_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/api/orders.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/selection_display.dart';
import 'package:rescape/ui/screens/main/pages/orders/list/order_list.dart';
import 'package:rescape/ui/shared/confirm_deletion_dialog.dart';

class CurrentOrders extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CurrentOrdersState();
  }
}

class _CurrentOrdersState extends State<CurrentOrders> {
  static Key _futureKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ListView(
        children: [
          SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    I18N.text('Current Orders'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () => setState(
                      () => _futureKey = UniqueKey(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Divider(height: 0),
          ),
          FutureBuilder(
            key: _futureKey,
            future: OrdersAPI().getCurrent(),
            builder: (context, orders) {
              if (orders.connectionState != ConnectionState.done ||
                  orders.hasError ||
                  !orders.hasData)
                return Center(
                  child: orders.connectionState != ConnectionState.done
                      ? CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            orders.hasError
                                ? orders.error.toString()
                                : I18N.text('No orders'),
                          ),
                        ),
                );
              else {
                List<CurrentOrderModel> _orders = [
                  for (var entry in orders.data.entries)
                    CurrentOrderModel(
                      time: DateTime.parse(entry.value['time']),
                      location: LocationList.instance
                          .firstWhere((e) => e.id == entry.value['location']),
                      items: [
                        for (var product in entry.value['items'])
                          OrderItemModel(
                            product: ProductList.instance.firstWhere((e) =>
                                e.barcode.length == 7 &&
                                    product['barcode'].startsWith(e.barcode) ||
                                e.barcode == product['barcode']),
                            measure: product['amount'],
                            forceMeasure: (product['forceMeasure'] ?? false),
                          ),
                      ],
                      key: entry.key,
                      vehicle: VehicleModel(
                        model: entry.value['vehicle']['model'],
                        plates: entry.value['vehicle']['plates'],
                      ),
                    ),
                ];
                return Column(
                  children: [
                    for (var order in _orders)
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: GestureDetector(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: kElevationToShadow[1],
                              color: Colors.white,
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 64,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      UserData.isOwner || UserData.isManager
                                          ? MainAxisAlignment.spaceBetween
                                          : MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      order.time.day.toString() +
                                          '.' +
                                          order.time.month.toString() +
                                          '.' +
                                          order.time.year.toString() +
                                          '. ' +
                                          order.location.companyName +
                                          (order.location.number != '0'
                                              ? ' ' + order.location.number
                                              : ''),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (UserData.isOwner || UserData.isManager)
                                      IconButton(
                                        onPressed: () async {
                                          Future<int> delete() async {
                                            int statusCode = 400;
                                            try {
                                              statusCode = (await OrdersAPI
                                                      .deleteCurrent(order.key))
                                                  .statusCode;
                                            } catch (e) {
                                              print(e);
                                            }
                                            return statusCode;
                                          }

                                          showDialog(
                                              context: context,
                                              barrierColor: Colors.white70,
                                              builder: (context) =>
                                                  ConfirmDeletionDialog(
                                                    future: delete,
                                                    rebuildParent: () {},
                                                  )).whenComplete(
                                              () => setState(() {}));
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          onTap: () => OrdersViewController.change(
                            OrderList(order: order),
                          ),
                        ),
                      ),
                  ],
                );
              }
            },
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
