import 'package:flutter/material.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/data/models/vehicle_model.dart';
import '../items_list_dialog/items_list_dialog.dart';

class CurrentOrderButton extends StatelessWidget {
  final Function scanning;
  final LocationModel location;
  final VehicleModel vehicle;
  final bool update;

  CurrentOrderButton({
    @required this.scanning,
    @required this.location,
    @required this.vehicle,
    @required this.update,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.grading, color: Theme.of(context).primaryColor),
      onPressed: () {
        scanning(false, true);
        showDialog(
          context: context,
          barrierColor: Colors.white,
          builder: (context) => ItemsListDialog(
            scanning: scanning,
            location: location,
            vehicle: vehicle,
            update: update,
          ),
        );
      },
    );
  }
}
