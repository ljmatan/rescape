import 'package:flutter/material.dart';
import 'package:rescape/ui/screens/main/pages/inventory/bloc/filter_controller.dart';

class InventoryFilterOption extends StatelessWidget {
  final String category, selected;
  final Function onTap;

  InventoryFilterOption({@required this.category, this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 56,
          child: Center(
            child: Text(
              category,
              style: TextStyle(
                fontWeight: selected != null && selected == category
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: selected != null && selected == category
                    ? Theme.of(context).primaryColor
                    : Colors.black,
                fontSize: selected != null && selected == category ? 18 : 16,
              ),
            ),
          ),
        ),
      ),
      onTap: onTap != null
          ? () => onTap()
          : () {
              InventoryFilterController.change(
                  selected != null && selected == category ? null : category);
              Navigator.pop(context);
            },
    );
  }
}
