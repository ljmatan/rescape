import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/logic/api/products.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/add_product/barcode_scanning.dart';
import 'package:rescape/ui/shared/result_dialog.dart';

class AddProductScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddProductScreenState();
  }
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _internalCodeController = TextEditingController();
  final _amountController = TextEditingController(text: '0.0');
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _measureController = TextEditingController();
  final _measureFocusNode = FocusNode();

  int _section = 0;

  Measure _measureType = Measure.kg;
  String _measure = 'KG';

  @override
  void initState() {
    super.initState();
    _measureController.addListener(() {
      if (_measureType == Measure.qty)
        _measure = 'QTY' + _measureController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Text(
                    I18N.text('New Product'),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _internalCodeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: I18N.text('Internal Code'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: I18N.text('Amount'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _barcodeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: I18N.text('Barcode'),
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 24, 48, 16),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(Icons.camera),
                          onPressed: () async {
                            final barcode = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AddProductBarcodeScan()));
                            if (barcode != null)
                              _barcodeController.text = barcode;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: I18N.text('Name'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: I18N.text('Category'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 22,
                        child: DropdownButton(
                          isExpanded: true,
                          value: _measureType,
                          items: [
                            DropdownMenuItem(
                              child: Text(I18N.text('Weight')),
                              value: Measure.kg,
                            ),
                            DropdownMenuItem(
                              child: Text(I18N.text('Quantity')),
                              value: Measure.qty,
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _measureType = value);
                            if (value == Measure.qty) {
                              _measureFocusNode.requestFocus();
                              _measureController.text = '1';
                            } else
                              _measure = 'KG';
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: TextField(
                          focusNode: _measureFocusNode,
                          controller: _measureController,
                          enabled: _measureType == Measure.qty,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: I18N.text('In pack'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Text(I18N.text('Section')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < 6; i++)
                        GestureDetector(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: _section == i ? 2 : 1,
                                color: _section == i
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
                                    fontWeight:
                                        _section == i ? FontWeight.bold : null,
                                    color: _section == i
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () => setState(() => _section = i),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: Center(
                              child: Text(
                                I18N.text('CANCEL'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              child: Center(
                                child: Text(
                                  I18N.text('CONFIRM'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            if (_internalCodeController.text.isNotEmpty &&
                                int.tryParse(_internalCodeController.text) !=
                                    null &&
                                _amountController.text.isNotEmpty &&
                                (_measureType == Measure.kg &&
                                        double.tryParse(
                                                _amountController.text) !=
                                            null ||
                                    _measureType == Measure.qty &&
                                        int.tryParse(double.parse(
                                                    _amountController.text)
                                                .toStringAsFixed(0)) !=
                                            null) &&
                                _barcodeController.text.isNotEmpty &&
                                _barcodeController.text != '3897900' &&
                                int.tryParse(_barcodeController.text) != null &&
                                ((_barcodeController.text.length == 13 &&
                                        _measureType == Measure.qty) ||
                                    (_barcodeController.text.length == 7 &&
                                        _measureType == Measure.kg)) &&
                                _nameController.text.isNotEmpty &&
                                _categoryController.text.isNotEmpty &&
                                (_measureType == Measure.kg
                                    ? true
                                    : int.tryParse(_measureController.text) !=
                                        null)) {
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
                              int statusCode;
                              try {
                                statusCode = (await ProductsAPI.create(
                                  double.parse(_amountController.text),
                                  int.parse(_measureType == Measure.kg
                                      ? _barcodeController.text.substring(0, 7)
                                      : _barcodeController.text),
                                  _categoryController.text,
                                  _measure,
                                  _nameController.text,
                                  int.parse(_internalCodeController.text),
                                  _section,
                                ))
                                    .statusCode;
                              } catch (e) {
                                statusCode = 400;
                              }
                              Navigator.pop(context);
                              ResultDialog.show(context, statusCode);
                            } else
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(I18N
                                          .text('Please check your info'))));
                          },
                        ),
                      ),
                    ],
                  ),
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
    _internalCodeController.dispose();
    _amountController.dispose();
    _barcodeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _measureController.dispose();
    _measureFocusNode.dispose();
    super.dispose();
  }
}
