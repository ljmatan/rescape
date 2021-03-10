import 'package:flutter/material.dart';
import 'package:rescape/data/product_list.dart';
import 'filter_option.dart';

class InventoryFilterDialog extends StatelessWidget {
  final String selected;

  InventoryFilterDialog({@required this.selected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Material(
          elevation: 16,
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < ProductList.categories.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                    child: InventoryFilterOption(
                      category: ProductList.categories.elementAt(i),
                      selected: selected,
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
