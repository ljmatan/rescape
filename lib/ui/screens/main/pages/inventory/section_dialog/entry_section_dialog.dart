import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/storage/local.dart';
import 'package:rescape/ui/screens/main/pages/inventory/section_dialog/bloc/selected_section_controller.dart';

class EntrySectionDialog extends StatefulWidget {
  final ProductModel product;

  EntrySectionDialog({@required this.product});

  @override
  State<StatefulWidget> createState() {
    return _EntrySectionDialogState();
  }
}

class _EntrySectionDialogState extends State<EntrySectionDialog> {
  @override
  void initState() {
    SelectedSectionController.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          elevation: 2,
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.product.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 10),
                  child: Text(
                    'Section',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 6; i++)
                      StreamBuilder(
                        stream: SelectedSectionController.stream,
                        initialData: widget.product.section,
                        builder: (context, selected) => GestureDetector(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: selected.data == i ? 2 : 1,
                                color: selected.data == i
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 8,
                              height: MediaQuery.of(context).size.width / 8,
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: selected.data == i
                                        ? FontWeight.bold
                                        : null,
                                    color: selected.data == i
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            showDialog(
                                context: context,
                                barrierColor: Colors.white70,
                                barrierDismissible: false,
                                builder: (context) =>
                                    Center(child: CircularProgressIndicator()));
                            try {
                              await ProductsAPI.setProductSection(
                                  widget.product.firebaseID, i);
                              await DB.instance.update(
                                'Products',
                                {'section': i},
                                where: 'product_id = ?',
                                whereArgs: ['${widget.product.id}'],
                              );
                              ProductList.instance
                                  .firstWhere((e) => e.id == widget.product.id)
                                  .section = i;
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } catch (e) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                            }
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
    );
  }

  @override
  void dispose() {
    SelectedSectionController.dispose();
    super.dispose();
  }
}
