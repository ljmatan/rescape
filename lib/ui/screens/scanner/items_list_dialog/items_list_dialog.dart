import 'package:flutter/material.dart';
import 'package:rescape/data/current_order.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/models/vehicle_model.dart';
import 'package:rescape/data/new_order.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/api/orders.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/logic/storage/local.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/new_order/company_selection/company_search.dart';
import 'package:rescape/ui/shared/result_dialog.dart';
import 'package:decimal/decimal.dart';

class ItemsListDialog extends StatefulWidget {
  final Function scanning;
  final LocationModel location;
  final VehicleModel vehicle;
  final bool update;

  ItemsListDialog({
    this.scanning,
    @required this.location,
    @required this.vehicle,
    @required this.update,
  });

  @override
  State<StatefulWidget> createState() {
    return _ItemsListDialogState();
  }
}

class _ItemsListDialogState extends State<ItemsListDialog> {
  void _back() {
    if (widget.scanning != null) widget.scanning(true, false);
    Navigator.pop(context);
  }

  @override
  void initState() {
    if (widget.scanning != null) widget.scanning(false, true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          if (NewOrder.instance.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  I18N.text('No items added'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          if (NewOrder.instance.isNotEmpty)
            ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () => setState(() => NewOrder.clear()),
                      ),
                      Text(
                        widget.update != null && widget.update
                            ? I18N.text('Inventory Update')
                            : widget.location != null
                                ? I18N.text('New Order')
                                : CurrentOrder.instance != null
                                    ? I18N.text('Current Order')
                                    : I18N.text('New Return'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                for (var item in NewOrder.instance)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: kElevationToShadow[1],
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 56,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red.shade300,
                                      ),
                                      onPressed: () =>
                                          setState(() => NewOrder.remove(item)),
                                    ),
                                    Flexible(
                                      child: Text(item.product.name),
                                    ),
                                  ],
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
                    ),
                  ),
              ],
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
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
                    onTap: () => _back(),
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
                            I18N.text('CONFIRM'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (NewOrder.instance.isEmpty)
                        _back();
                      else if (widget.update) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.white70,
                            builder: (context) => WillPopScope(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                                onWillPop: () async => false));
                        final Map productsMap = {
                          for (var item in NewOrder.instance)
                            for (var product in ProductList.instance
                                .where((e) => e.id == item.product.id))
                              product.barcode: {
                                'product_id': item.product.id,
                                'available': double.parse((Decimal.parse(
                                            ProductList
                                                .instance
                                                .firstWhere((e) => item.product
                                                            .measureType ==
                                                        Measure.qty
                                                    ? e.barcode ==
                                                        item.product.barcode
                                                    : e.barcode.substring(
                                                            0, 7) ==
                                                        item.product.barcode
                                                            .substring(0, 7))
                                                .available
                                                .toString()) +
                                        Decimal.parse(item.measure.toString()))
                                    .toString()),
                                'name': product.name,
                                'barcode': product.measureType == Measure.kg
                                    ? product.barcode.substring(0, 7)
                                    : product.barcode,
                                'measure':
                                    item.product.measureType == Measure.kg
                                        ? 'KG'
                                        : 'QTY' + product.quantity.toString(),
                                'section': product.section,
                                'category': item.product.category,
                              }
                        };
                        int statusCode = 400;
                        try {
                          final response =
                              await ProductsAPI.massProductAvailabilityUpdate(
                                  productsMap);
                          statusCode = response.statusCode;
                        } catch (e) {
                          print(e);
                        }
                        if (statusCode == 200)
                          for (var item in NewOrder.instance)
                            for (var product in ProductList.instance
                                .where((e) => e.id == item.product.id)) {
                              product.available = double.parse((Decimal.parse(
                                          product.available.toString()) +
                                      Decimal.parse(item.measure.toString()))
                                  .toString());
                              await DB.instance.update(
                                'Products',
                                {'available': product.available},
                                where: 'product_id = ?',
                                whereArgs: [item.product.id],
                              );
                            }
                        Navigator.pop(context);
                        await ResultDialog.show(context, statusCode, true);
                        Navigator.pop(context);
                      } else if (widget.location != null) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.white70,
                            builder: (context) => WillPopScope(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                                onWillPop: () async => false));
                        int statusCode = 400;
                        try {
                          final response = await OrdersAPI.create(
                            {
                              'location': widget.location.id,
                              'time': DateTime.now().toIso8601String(),
                              'items': [
                                for (var item in NewOrder.instance)
                                  {
                                    'barcode': item.product.measureType ==
                                            Measure.kg
                                        ? item.product.barcode.substring(0, 7)
                                        : item.product.barcode,
                                    'amount': item.measure,
                                    if (item.product.measureType ==
                                            Measure.qty &&
                                        item.product.barcode.length == 7)
                                      'forceMeasure': true,
                                  },
                              ],
                              'vehicle': {
                                'model': widget.vehicle.model,
                                'plates': widget.vehicle.plates,
                              },
                            },
                          );
                          statusCode = response.statusCode;
                        } catch (e) {
                          print(e);
                        }
                        Navigator.pop(context);
                        await ResultDialog.show(context, statusCode, true);
                        Navigator.pop(context);
                      } else if (CurrentOrder.instance != null) {
                        final DateTime date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          locale: Locale.fromSubtags(
                            languageCode: I18N.locale,
                            scriptCode: I18N.locale == 'sr' ? 'Latn' : null,
                          ),
                        );
                        if (date != null) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.white70,
                              builder: (context) => WillPopScope(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  onWillPop: () async => false));
                          int statusCode = 400;
                          try {
                            statusCode = await OrdersAPI.orderPrepared(
                              {
                                'location': CurrentOrder.instance.location.id,
                                'time': date.toIso8601String(),
                                'items': [
                                  for (var item in NewOrder.instance)
                                    {
                                      'barcode': item.product.measureType ==
                                              Measure.kg
                                          ? item.product.barcode.substring(0, 7)
                                          : item.product.barcode,
                                      'amount': item.measure,
                                    },
                                ],
                                'vehicle': {
                                  'model': CurrentOrder.instance.vehicle.model,
                                  'plates':
                                      CurrentOrder.instance.vehicle.plates,
                                },
                              },
                              CurrentOrder.instance.key,
                            );
                          } catch (e) {
                            print(e);
                          }
                          Navigator.pop(context);
                          await ResultDialog.show(context, statusCode, true);
                          Navigator.pop(context);
                        }
                      } else {
                        final location = await showDialog(
                          context: context,
                          barrierColor: Colors.white,
                          builder: (context) => Material(
                            color: Colors.white,
                            child: CompanySearch(popup: true),
                          ),
                        );
                        if (location != null) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierColor: Colors.white70,
                              builder: (context) => WillPopScope(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  onWillPop: () async => false));
                          int statusCode = 400;
                          try {
                            final response = await OrdersAPI.createReturn(
                              {
                                'time': DateTime.now().toIso8601String(),
                                'items': [
                                  for (var item in NewOrder.instance)
                                    {
                                      'barcode': item.product.measureType ==
                                              Measure.kg
                                          ? item.product.barcode.substring(0, 7)
                                          : item.product.barcode,
                                      'amount': item.measure,
                                    },
                                ],
                                'submitter': UserData.instance.name,
                                'location': location.id,
                              },
                            );
                            statusCode = response.statusCode;
                          } catch (e) {
                            print(e);
                          }
                          Navigator.pop(context);
                          await ResultDialog.show(context, statusCode, true);
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (widget.scanning != null) widget.scanning(true, false);
    super.dispose();
  }
}
