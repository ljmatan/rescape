import 'package:flutter/material.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/main/pages/inventory/bloc/filter_controller.dart';
import 'package:rescape/ui/screens/main/pages/inventory/filter_dialog/filter_dialog.dart';
import 'package:rescape/ui/screens/main/pages/inventory/inventory_entry.dart';
import 'package:rescape/ui/shared/blocking_dialog.dart';
import 'package:rescape/ui/shared/pdf_doc_display.dart';

class InventoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InventoryPageState();
  }
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    super.initState();
    InventoryFilterController.init();
  }

  void _rebuild() => setState(() {});

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
                  12,
                  MediaQuery.of(context).padding.top,
                  12,
                  0,
                ),
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
                      children: [
                        IconButton(
                          icon: Icon(Icons.list),
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
                            for (var product in ProductList.instance)
                              InventoryEntry(
                                product: product,
                                rebuildParent: _rebuild,
                              )
                          else
                            for (var product in ProductList.instance
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
