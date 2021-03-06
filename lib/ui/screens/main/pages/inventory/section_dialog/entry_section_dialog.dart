import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/data/user_data.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/logic/storage/local.dart';
import 'package:rescape/ui/screens/main/pages/inventory/section_dialog/bloc/selected_section_controller.dart';
import 'package:rescape/ui/shared/confirm_deletion_dialog.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class EntrySectionDialog extends StatefulWidget {
  final ProductModel product;
  final Function rebuildParent;

  EntrySectionDialog({
    @required this.product,
    @required this.rebuildParent,
  });

  @override
  State<StatefulWidget> createState() {
    return _EntrySectionDialogState();
  }
}

class _EntrySectionDialogState extends State<EntrySectionDialog> {
  TextEditingController _availableController;

  Future<void> _delete(String barcode) async {
    try {
      await DB.instance
          .delete('Products', where: 'barcode = ?', whereArgs: [barcode])
          .whenComplete(() async {
            for (var product
                in ProductList.instance.where((e) => e.barcode == barcode)) {
              await ProductsAPI.deleteProduct(product.barcode);
              break;
            }
          })
          .whenComplete(() =>
              ProductList.instance.removeWhere((e) => e.barcode == barcode))
          .whenComplete(() => widget.rebuildParent());
    } catch (e) {
      return 400;
    }
    return 200;
  }

  @override
  void initState() {
    super.initState();
    SelectedSectionController.init();
    if (UserData.isOwner || UserData.isManager)
      _availableController = TextEditingController(
          text: widget.product.measureType == Measure.kg
              ? widget.product.available.toString()
              : widget.product.available.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    void delete() => _delete(widget.product.barcode);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            12, 0, 12, 12 + MediaQuery.of(context).viewInsets.bottom),
        child: Material(
          elevation: 2,
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    widget.product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (UserData.isOwner || UserData.isManager)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(I18N.text('Available') + ':'),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: TextField(
                          controller: _availableController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 10),
                  child: Text(
                    I18N.text('Section'),
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
                                  widget.product.measureType == Measure.kg
                                      ? widget.product.barcode.substring(0, 7)
                                      : widget.product.barcode,
                                  i);
                              await DB.instance.update(
                                'Products',
                                {'section': i},
                                where: 'id = ?',
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
                if (UserData.isOwner)
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 10),
                    child: GestureDetector(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).primaryColor,
                          boxShadow: kElevationToShadow[1],
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 48,
                          child: Center(
                            child: Text(
                              I18N.text('DELETE'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          barrierColor: Colors.white70,
                          builder: (context) => ConfirmDeletionDialog(
                            rebuildParent: widget.rebuildParent,
                            future: delete,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                if (UserData.isOwner || UserData.isManager)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: Center(
                              child: Text(
                                I18N.text('CANCEL'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context).primaryColor,
                              boxShadow: kElevationToShadow[1],
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              child: Center(
                                child: Text(
                                  I18N.text('UPDATE'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (_availableController.text ==
                                widget.product.available.toString())
                              Navigator.pop(context);
                            else if (double.tryParse(
                                    _availableController.text) ==
                                null) {
                              Navigator.of(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(I18N
                                          .text('You must enter a number'))));
                            } else {
                              FocusScope.of(context).unfocus();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.white70,
                                builder: (context) => WillPopScope(
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                  onWillPop: () async => false,
                                ),
                              );
                              try {
                                final double newAmount =
                                    double.parse(_availableController.text);
                                int statusCode = 400;
                                for (var product in ProductList.instance
                                    .where((e) => e.id == widget.product.id)) {
                                  final response =
                                      await ProductsAPI.setProductAvailability(
                                          product.barcode, newAmount);
                                  if (response.statusCode != 200) {
                                    statusCode = 400;
                                    break;
                                  } else
                                    statusCode = 200;
                                }
                                if (statusCode == 200) {
                                  ProductList.instance
                                      .firstWhere((e) =>
                                          e.barcode == widget.product.barcode)
                                      .available = newAmount;
                                  await DB.instance.update(
                                    'Products',
                                    {'available': newAmount},
                                    where: 'barcode = ?',
                                    whereArgs: [widget.product.barcode],
                                  );
                                }
                                Navigator.pop(context);
                                ResultDialog.show(context, statusCode);
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$e')));
                              }
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
    _availableController?.dispose();
    super.dispose();
  }
}
