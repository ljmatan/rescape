import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/ui/screens/scanner/new_order_elements/add_item_dialog.dart';

class ProductEntry extends StatelessWidget {
  final ProductModel product;

  ProductEntry({@required this.product});

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
                    child: Text(product.name),
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
          ProductModel edited = product;
          if (edited.measureType == Measure.kg)
            edited.barcode = edited.barcode + '010000';
          await showDialog(
            context: context,
            barrierColor: Colors.white70,
            builder: (context) => AddItemDialog(
              product: edited,
              autofocus: true,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}
