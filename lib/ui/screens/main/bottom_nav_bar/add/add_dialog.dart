import 'package:flutter/material.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/add_product/add_product_screen.dart';
import 'package:rescape/ui/screens/employee_managment/add_employee/add_employee_screen.dart';
import 'package:rescape/ui/screens/employee_managment/remove_employee_screen.dart';
import 'package:rescape/ui/screens/main/bloc/main_view_controller.dart';
import 'package:rescape/ui/screens/scanner/camera_screen.dart';
import 'employee_managment.dart';
import 'entry_display.dart';

class AddDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 82),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[1],
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AddEntryDisplay(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory, size: 64),
                        Text(I18N.text('Inventory Update'),
                            textAlign: TextAlign.center),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              CameraScreen(update: true)));
                      MainViewController.change(0);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                AddEntryDisplay(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 64),
                        Text(
                          I18N.text('Add a Product'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AddProductScreen()));
                    },
                  ),
                ),
                const SizedBox(height: 12),
                AddEntryDisplay(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (UserData.isOwner)
                        EmployeeManagment(
                          icon: Icons.person_remove,
                          label: I18N.text('Remove Employee'),
                          route: RemoveEmployeeScreen(),
                        ),
                      EmployeeManagment(
                        icon: Icons.person_add,
                        label: I18N.text('New Employee'),
                        route: AddEmployeeScreen(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
