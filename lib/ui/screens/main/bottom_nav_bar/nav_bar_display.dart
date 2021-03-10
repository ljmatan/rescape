import 'package:flutter/material.dart';
import 'add/add_button.dart';
import 'custom_icon.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(width: 0.1),
                ),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 56 + MediaQuery.of(context).padding.bottom,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 56 + MediaQuery.of(context).padding.bottom,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CustomNavBarIcon(
                        icon: Icons.explore,
                        label: 'NAVIGATE',
                        index: 0,
                      ),
                      CustomNavBarIcon(
                        icon: Icons.store,
                        label: 'INVENTORY',
                        index: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 74, height: 56),
                Expanded(
                  child: Row(
                    children: [
                      CustomNavBarIcon(
                        icon: Icons.local_shipping,
                        label: 'ORDERS',
                        index: 2,
                      ),
                      CustomNavBarIcon(
                        icon: Icons.notifications,
                        label: 'REPORTS',
                        index: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AddButton(),
      ],
    );
  }
}
