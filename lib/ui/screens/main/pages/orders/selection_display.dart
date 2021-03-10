import 'package:flutter/material.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/current_orders/current_orders.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/new_order/company_selection/company_search.dart';

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
          SelectionOption(
            label: 'Previous Orders',
            icon: Icons.history,
            route: null,
          ),
          const SizedBox(height: 12),
          SelectionOption(
            label: 'Create an Order',
            icon: Icons.add_circle_outline,
            route: CompanySearch(),
          ),
          const SizedBox(height: 12),
          SelectionOption(
            label: 'Current Orders',
            icon: Icons.assignment,
            route: CurrentOrders(),
          ),
        ],
      ),
    );
  }
}
