import 'package:flutter/material.dart';
import 'package:rescape/data/company_list.dart';
import 'package:rescape/data/models/current_order_model.dart';
import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/data/models/vehicle_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/api/orders.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/selection_display.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/current_orders/order_list.dart';

class CurrentOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: FutureBuilder(
        future: OrdersAPI.getCurrent(),
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
                        product: ProductList.instance.firstWhere(
                          (e) => e.id == product['id'],
                        ),
                        measure: product['amount'],
                      ),
                  ],
                  key: entry.key,
                  vehicle: VehicleModel(
                    model: entry.value['vehicle']['model'],
                    plates: entry.value['vehicle']['plates'],
                  ),
                ),
            ];
            return ListView(
              reverse: true,
              padding: const EdgeInsets.only(bottom: 16),
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
                          child: Center(
                            child: Text(
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
      onWillPop: () async {
        OrdersViewController.change(SelectionDisplay());
        return false;
      },
    );
  }
}
