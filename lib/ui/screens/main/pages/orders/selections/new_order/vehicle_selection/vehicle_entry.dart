import 'package:flutter/material.dart';
import 'package:rescape/data/models/vehicle_model.dart';

class VehicleEntry extends StatelessWidget {
  final MapEntry entry;

  VehicleEntry(this.entry);

  @override
  Widget build(BuildContext context) {
    final VehicleModel vehicle = VehicleModel(
      model: entry.key,
      plates: entry.value['plates'],
      category: entry.value['category'],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: kElevationToShadow[1],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: Icon(
                          vehicle.category == 0
                              ? Icons.drive_eta
                              : Icons.local_shipping,
                        ),
                      ),
                      Text(vehicle.model),
                    ],
                  ),
                  Text(
                    vehicle.plates,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () => Navigator.pop(context, vehicle),
      ),
    );
  }
}
