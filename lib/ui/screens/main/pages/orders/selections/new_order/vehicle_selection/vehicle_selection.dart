import 'package:flutter/material.dart';
import 'package:rescape/logic/api/vehicles.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/new_order/vehicle_selection/vehicle_entry.dart';

class VehicleSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 12,
              left: 12,
              right: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  I18N.text('Vehicles'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: VehiclesAPI.getVehicles(),
              builder: (context, vehicles) => vehicles.connectionState !=
                          ConnectionState.done ||
                      vehicles.hasError
                  ? Center(
                      child: vehicles.connectionState != ConnectionState.done
                          ? CircularProgressIndicator()
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(vehicles.error),
                            ),
                    )
                  : ListView(
                      reverse: true,
                      children: [
                        for (var vehicle in vehicles.data.entries)
                          VehicleEntry(vehicle)
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
