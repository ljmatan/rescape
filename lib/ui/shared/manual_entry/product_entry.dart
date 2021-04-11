import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/ui/screens/scanner/new_order_elements/add_item_dialog.dart';

class ProductEntry extends StatelessWidget {
  final ProductModel product;
  final bool newOrder;

  ProductEntry({@required this.product, this.newOrder: false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: kElevationToShadow[2],
            color: Colors.white,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 64,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('${product.id}'),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${product.name}' +
                          (ProductList.instance
                                      .where((e) => e.id == product.id)
                                      .length >
                                  1
                              ? ' ×${product.quantity}'
                              : ''),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    product.measureType == Measure.kg
                        ? '${product.available}kg'
                        : '×${product.available.floor()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () async {
          await showDialog(
            context: context,
            barrierColor: Colors.white70,
            builder: (context) => AddItemDialog(
              product: product,
              autofocus: true,
              newOrder: newOrder,
            ),
          );
          if (!newOrder) Navigator.pop(context);
        },
      ),
    );
  }
}
