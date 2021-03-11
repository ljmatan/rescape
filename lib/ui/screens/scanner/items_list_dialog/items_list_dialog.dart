import 'package:flutter/material.dart';
import 'package:rescape/data/current_order.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/models/vehicle_model.dart';
import 'package:rescape/data/new_order.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/api/orders.dart';
import 'package:rescape/ui/screens/scanner/items_list_dialog/success_dialog.dart';

class ItemsListDialog extends StatefulWidget {
  final String label;
  final Function scanning;
  final LocationModel location;
  final VehicleModel vehicle;

  ItemsListDialog({
    @required this.label,
    @required this.scanning,
    @required this.location,
    @required this.vehicle,
  });

  @override
  State<StatefulWidget> createState() {
    return _ItemsListDialogState();
  }
}

class _ItemsListDialogState extends State<ItemsListDialog> {
  void _back() {
    widget.scanning(true, false);
    Navigator.pop(context);
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
                  'No items added',
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
                  child: Center(
                    child: Text(
                      widget.location != null
                          ? 'New Order'
                          : CurrentOrder.instance != null
                              ? 'Current Order'
                              : 'New Return',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
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
                          'BACK',
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
                            'CONFIRM',
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
                      else if (widget.location != null) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.white70,
                            builder: (context) => WillPopScope(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                                onWillPop: () async => false));
                        await OrdersAPI.create(
                          {
                            'location': widget.location.id,
                            'time': DateTime.now().toIso8601String(),
                            'items': [
                              for (var item in NewOrder.instance)
                                {
                                  'id': item.product.id,
                                  'amount': item.measure,
                                },
                            ],
                            'vehicle': {
                              'model': widget.vehicle.model,
                              'plates': widget.vehicle.plates,
                            },
                          },
                        );
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.white70,
                          builder: (context) =>
                              SuccessDialog(label: 'Order added!'),
                        );
                      } else if (CurrentOrder.instance != null) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.white70,
                            builder: (context) => WillPopScope(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                                onWillPop: () async => false));
                        await OrdersAPI.orderPrepared(
                          {
                            'location': CurrentOrder.instance.location.id,
                            'time':
                                CurrentOrder.instance.time.toIso8601String(),
                            'items': [
                              for (var item in NewOrder.instance)
                                {
                                  'id': item.product.id,
                                  'amount': item.measure,
                                },
                            ],
                            'vehicle': {
                              'model': CurrentOrder.instance.vehicle.model,
                              'plates': CurrentOrder.instance.vehicle.plates,
                            },
                          },
                          CurrentOrder.instance.key,
                        );
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.white70,
                          builder: (context) => SuccessDialog(
                              label: 'Order successfully prepared!'),
                        );
                      } else {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.white70,
                            builder: (context) => WillPopScope(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                                onWillPop: () async => false));
                        await OrdersAPI.createReturn(
                          {
                            'time':
                                CurrentOrder.instance.time.toIso8601String(),
                            'items': [
                              for (var item in NewOrder.instance)
                                {
                                  'id': item.product.id,
                                  'amount': item.measure,
                                },
                            ],
                            'submitter': UserData.instance.name,
                          },
                        );
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.white70,
                          builder: (context) =>
                              SuccessDialog(label: 'Return info forwarded'),
                        );
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
}
