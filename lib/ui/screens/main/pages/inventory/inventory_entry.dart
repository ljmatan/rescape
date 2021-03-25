import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/ui/screens/main/pages/inventory/section_dialog/entry_section_dialog.dart';

class InventoryEntry extends StatefulWidget {
  final ProductModel product;
  final Function rebuildParent;

  InventoryEntry({@required this.product, @required this.rebuildParent});

  @override
  State<StatefulWidget> createState() {
    return _InventoryEntryState();
  }
}

class _InventoryEntryState extends State<InventoryEntry> {
  @override
  Widget build(BuildContext context) {
    ProductModel thisProduct =
        ProductList.instance.firstWhere((e) => e.id == widget.product.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: kElevationToShadow[1],
            color: Colors.white,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 64,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('${thisProduct.id}'),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(widget.product.name),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.product.measureType == Measure.kg
                        ? '${thisProduct.available}kg'
                        : '×${thisProduct.available.floor()}',
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
            builder: (context) => EntrySectionDialog(
              rebuildParent: widget.rebuildParent,
              product: thisProduct,
            ),
          );
          setState(() {});
        },
      ),
    );
  }
}
