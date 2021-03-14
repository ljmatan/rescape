import 'package:flutter/material.dart';
import 'package:rescape/data/company_list.dart';
import 'package:rescape/data/models/current_order_model.dart';
import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/api/orders.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/shared/blocking_dialog.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class ReturnsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReturnsScreenState();
  }
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Text(
          I18N.text('Returns'),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: FutureBuilder(
        future: OrdersAPI.getReturns(),
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
                          (e) => e.barcode == product['barcode'],
                        ),
                        measure: product['amount'],
                      ),
                  ],
                  key: entry.key,
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
                      onTap: () => showDialog(
                        context: context,
                        barrierColor: Colors.white,
                        builder: (context) => Material(
                          color: Colors.white,
                          child: Stack(
                            children: [
                              ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(order.location.companyName +
                                            (order.location.number == '0'
                                                ? ''
                                                : order.location.number)),
                                        Text(order.time.day.toString() +
                                            '.' +
                                            order.time.month.toString() +
                                            '.' +
                                            order.time.year.toString() +
                                            '.'),
                                      ],
                                    ),
                                  ),
                                  for (var item in order.items)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          boxShadow: kElevationToShadow[1],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Colors.white,
                                        ),
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 56,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 12),
                                                  child: Text(item.product.id
                                                      .toString()),
                                                ),
                                                Flexible(
                                                  child:
                                                      Text(item.product.name),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 12),
                                                  child: Text(
                                                    item.product.measureType ==
                                                            Measure.kg
                                                        ? '${item.measure}kg'
                                                        : '×${item.measure.floor()}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 72),
                                ],
                              ),
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 16,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 48,
                                          child: Center(
                                            child: Text(
                                              I18N.text('BACK'),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            boxShadow: kElevationToShadow[1],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 48,
                                            child: Center(
                                              child: Text(
                                                I18N.text('DELETE'),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          BlockingDialog.show(context);
                                          try {
                                            final response =
                                                await OrdersAPI.deleteReturn(
                                                    order.key);
                                            Navigator.pop(context);
                                            await ResultDialog.show(
                                                context, response.statusCode);
                                            setState(() {});
                                          } catch (e) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text('$e')));
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
