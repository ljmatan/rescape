import 'package:flutter/material.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/current_orders/current_orders.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/new_order/company_selection/company_search.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/previous_orders/previous_orders.dart';

class SelectionOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget route;

  SelectionOption({
    @required this.icon,
    @required this.label,
    @required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[2],
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 74,
                  ),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        onTap: () => OrdersViewController.change(route),
      ),
    );
  }
}

class SelectionDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 18,
        18,
        34,
      ),
      child: Column(
        children: [
          if (UserData.isOwner || UserData.isManager)
            SelectionOption(
              label: I18N.text('Previous Orders'),
              icon: Icons.history,
              route: PreviousOrders(),
            ),
          if (UserData.isOwner || UserData.isManager)
            const SizedBox(height: 12),
          SelectionOption(
            label: I18N.text('Create an Order'),
            icon: Icons.add_circle_outline,
            route: CompanySearch(),
          ),
          const SizedBox(height: 12),
          SelectionOption(
            label: I18N.text('Current Orders'),
            icon: Icons.assignment,
            route: CurrentOrders(),
          ),
        ],
      ),
    );
  }
}
