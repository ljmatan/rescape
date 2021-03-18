import 'package:flutter/material.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/vehicle_model.dart';
import 'package:rescape/data/new_order.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/scanner/items_list_dialog/items_list_dialog.dart';
import 'package:rescape/ui/shared/manual_entry/manual_entry_dialog.dart';

class NewOrderScreen extends StatefulWidget {
  final LocationModel location;
  final VehicleModel vehicle;

  NewOrderScreen({@required this.location, @required this.vehicle});

  @override
  State<StatefulWidget> createState() {
    return _NewOrderScreenState();
  }
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black26, width: 0.5),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 6,
                bottom: 6,
                left: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    I18N.text('New Order'),
                    style: const TextStyle(fontSize: 19),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.list),
                        onPressed: () => showDialog(
                          context: context,
                          barrierColor: Colors.white,
                          builder: (context) => ItemsListDialog(
                            location: widget.location,
                            vehicle: widget.vehicle,
                            update: false,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ManualEntryDialogDialog(newOrder: true),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    NewOrder.clear();
    super.dispose();
  }
}
