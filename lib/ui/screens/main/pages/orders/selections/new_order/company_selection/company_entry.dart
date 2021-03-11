import 'package:flutter/material.dart';
import 'package:rescape/data/company_list.dart';
import 'package:rescape/data/models/company_model.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/selection_display.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/new_order/vehicle_selection/vehicle_selection.dart';
import 'package:rescape/ui/screens/scanner/camera_screen.dart';

class LocationNumberRow extends StatelessWidget {
  final int upTo;
  final List<LocationModel> companyLocations;

  LocationNumberRow({@required this.upTo, @required this.companyLocations});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < upTo; i++)
          GestureDetector(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: kElevationToShadow[1],
                color: Theme.of(context).primaryColor,
              ),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text(
                    companyLocations[i].number,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            onTap: () async {
              final selected = await showDialog(
                context: context,
                barrierColor: Colors.white,
                builder: (context) => VehicleSelection(),
              );
              if (selected != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => CameraScreen(
                        vehicle: selected,
                        location: LocationList.instance.firstWhere((e) =>
                            e.companyName == companyLocations[i].companyName &&
                            e.number == companyLocations[i].number))));
                OrdersViewController.change(SelectionDisplay());
              }
            },
          ),
      ],
    );
  }
}

class CompanyEntry extends StatefulWidget {
  final String label;
  final bool popup;

  CompanyEntry({@required this.label, @required this.popup});

  @override
  State<StatefulWidget> createState() {
    return _CompanyEntryState();
  }
}

class _CompanyEntryState extends State<CompanyEntry> {
  List<LocationModel> _companyLocations = [];

  CrossFadeState _crossFadeState = CrossFadeState.showFirst;

  @override
  void initState() {
    super.initState();
    for (var location in LocationList.instance)
      if (location.companyName == widget.label) _companyLocations.add(location);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: kElevationToShadow[1],
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width,
          height: _crossFadeState != CrossFadeState.showFirst &&
                  _companyLocations.length > 7
              ? 128
              : 64,
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 400),
            firstChild: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            secondChild: SizedBox(
              height: _companyLocations.length > 7 ? 128 : 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LocationNumberRow(
                    upTo: _companyLocations.length > 7
                        ? 7
                        : _companyLocations.length,
                    companyLocations: _companyLocations,
                  ),
                  if (_companyLocations.length > 7) const SizedBox(height: 10),
                  if (_companyLocations.length > 7)
                    LocationNumberRow(
                      upTo: _companyLocations.length > 14
                          ? 14
                          : _companyLocations.length,
                      companyLocations: _companyLocations,
                    ),
                ],
              ),
            ),
            crossFadeState: _crossFadeState,
          ),
        ),
        onTap: () async {
          if (_companyLocations.length > 1) {
            setState(() => _crossFadeState = CrossFadeState.showSecond);
            return;
          }
          final location = LocationList.instance
              .firstWhere((e) => e.companyName == widget.label);
          if (widget.popup == true)
            Navigator.pop(context, location);
          else {
            final selected = await showDialog(
              context: context,
              barrierColor: Colors.white,
              builder: (context) => VehicleSelection(),
            );
            if (selected != null) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => CameraScreen(
                      vehicle: selected,
                      location: LocationList.instance
                          .firstWhere((e) => e.companyName == widget.label))));
              OrdersViewController.change(SelectionDisplay());
            }
          }
        },
      ),
    );
  }
}
