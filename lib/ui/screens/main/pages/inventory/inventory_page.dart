import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/main/pages/inventory/bloc/filter_controller.dart';
import 'package:rescape/ui/screens/main/pages/inventory/filter_dialog/filter_dialog.dart';
import 'package:rescape/ui/screens/main/pages/inventory/inventory_entry.dart';
import 'package:rescape/ui/shared/blocking_dialog.dart';
import 'package:rescape/ui/shared/pdf_doc_display.dart';
import 'package:decimal/decimal.dart';

class InventoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InventoryPageState();
  }
}

class _InventoryPageState extends State<InventoryPage> {
  Set<int> _internalCodes;

  List<ProductModel> _products;

  void _init() {
    if (_products == null)
      _products = [];
    else
      _products.clear();
    if (_internalCodes != null) _internalCodes.clear();
    _internalCodes = {for (var product in ProductList.instance) product.id};
    for (var code in _internalCodes) {
      num itemAvailable = 0;
      for (var product in ProductList.instance.where((e) => e.id == code))
        itemAvailable += double.parse((Decimal.parse(itemAvailable.toString()) +
                Decimal.parse(product.available.toString()))
            .toString());
      final ProductModel thisItem =
          ProductList.instance.firstWhere((e) => e.id == code);
      _products.add(ProductModel(
        name: thisItem.name,
        barcode: thisItem.barcode,
        category: thisItem.category,
        section: thisItem.section,
        available: itemAvailable,
        id: thisItem.id,
        quantity: thisItem.quantity,
        measureType: thisItem.measureType,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    InventoryFilterController.init();
    _init();
  }

  void _rebuild() => setState(() => _init());

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).padding.top + 70,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    12, MediaQuery.of(context).padding.top, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateTime.now().day.toString() +
                          '.' +
                          DateTime.now().month.toString() +
                          '.' +
                          DateTime.now().year.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.picture_as_pdf_outlined),
                          onPressed: () => showDialog(
                            context: context,
                            barrierColor: Colors.grey.shade200,
                            builder: (context) => PDFDocDisplay(
                              screenWidth: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () async {
                            BlockingDialog.show(context);
                            try {
                              await ProductsAPI.getList();
                              setState(() {});
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                            }
                            Navigator.pop(context);
                          },
                        ),
                        StreamBuilder(
                          stream: InventoryFilterController.stream,
                          builder: (context, selected) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: Icon(Icons.menu),
                            onTap: () async {
                              final rebuild = await showDialog(
                                context: context,
                                barrierColor: Colors.white70,
                                builder: (context) => InventoryFilterDialog(
                                  selected: selected.data,
                                ),
                              );
                              if (rebuild != null) setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 56,
                  child: Center(
                    child: Text(
                      I18N.text('STOCK'),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: StreamBuilder(
                    stream: InventoryFilterController.stream,
                    builder: (context, filter) {
                      return Column(
                        children: [
                          if (!filter.hasData)
                            for (var product in _products)
                              InventoryEntry(
                                product: product,
                                rebuildParent: _rebuild,
                              )
                          else
                            for (var product in _products
                                .where((e) => e.category == filter.data))
                              InventoryEntry(
                                product: product,
                                rebuildParent: _rebuild,
                              ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    InventoryFilterController.dispose();
    super.dispose();
  }
}
