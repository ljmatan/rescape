import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/new_order.dart';
import 'package:rescape/logic/barcode/processing.dart';
import 'package:rescape/logic/i18n/i18n.dart';

enum PackageType { pcs, box }

class PackageTypeSelection extends StatelessWidget {
  final StreamController streamController;
  final PackageType type;
  final String label;

  PackageTypeSelection({
    @required this.streamController,
    @required this.type,
    @required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: streamController.stream,
        initialData: PackageType.pcs,
        builder: (context, selected) => GestureDetector(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: selected.data == type
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 48,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected.data == PackageType.pcs
                        ? FontWeight.bold
                        : null,
                    color: selected.data == type
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          onTap: () => streamController.add(type),
        ),
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  final ProductModel product;
  final bool autofocus, newOrder;

  AddItemDialog({
    @required this.product,
    this.autofocus = false,
    this.newOrder = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _AddItemDialogState();
  }
}

class _AddItemDialogState extends State<AddItemDialog> {
  TextEditingController _qtyController;
  TextEditingController _weightController;

  double _quantity;
  double _weight;

  bool _measureInQty;

  PackageType _selectedType;
  StreamController _packageTypeController;
  StreamSubscription _packageTypeSubscription;

  @override
  void initState() {
    super.initState();
    _measureInQty = widget.product.measureType == Measure.qty;
    if (_measureInQty) {
      _quantity = widget.product.quantity.toDouble();
      _qtyController =
          TextEditingController(text: '${widget.product.quantity}');
    } else {
      _weight = widget.product.barcode.length == 7
          ? 1
          : BarcodeProcessing.weight(widget.product.barcode);
      _weightController = TextEditingController(text: '$_weight');
    }
    _qtyController
        ?.addListener(() => _quantity = double.tryParse(_qtyController.text));
    _weightController
        ?.addListener(() => _weight = double.tryParse(_weightController.text));
    if (_measureInQty) {
      _packageTypeController = StreamController.broadcast();
      _selectedType = PackageType.pcs;
      _packageTypeSubscription =
          _packageTypeController.stream.listen((type) => setState(() {
                _quantity = 1;
                _qtyController.text = '1';
                _selectedType = type;
              }));
    }
  }

  void _confirm() {
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
    if (_quantity == null && _weight == null ||
        _quantity != null && _quantity.runtimeType != double ||
        _weight != null && _weight.runtimeType != double)
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(I18N.text('Please check your info'))));
    else {
      NewOrder.add(
        OrderItemModel(
          product: widget.product,
          measure: _measureInQty
              ? _selectedType == PackageType.box
                  ? _quantity * widget.product.quantity
                  : _quantity
              : _weight,
        ),
        widget.newOrder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Material(
            elevation: 2,
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.product.name +
                        (_measureInQty ? ' x${widget.product.quantity}' : ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 26),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _measureInQty
                            ? DropdownButton(
                                value: _selectedType,
                                items: [
                                  DropdownMenuItem(
                                    child: Text(
                                      I18N.text('Pieces'),
                                    ),
                                    value: PackageType.pcs,
                                  ),
                                  DropdownMenuItem(
                                    child: Text(
                                      I18N.text('Boxes'),
                                    ),
                                    value: PackageType.box,
                                  ),
                                ],
                                onChanged: (value) =>
                                    _packageTypeController.add(value),
                              )
                            : Text(I18N.text('Kgs') + ':'),
                        SizedBox(
                          width: 150,
                          height: 56,
                          child: TextField(
                            autofocus: widget.autofocus,
                            maxLength: _measureInQty ? 3 : 7,
                            controller: _qtyController ?? _weightController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onEditingComplete: () => _confirm(),
                            buildCounter: (BuildContext context,
                                    {int currentLength,
                                    int maxLength,
                                    bool isFocused}) =>
                                null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.close,
                          color: Colors.red.shade300,
                          size: 56,
                        ),
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 26),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).primaryColor,
                          size: 56,
                        ),
                        onTap: () => _confirm(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _qtyController?.dispose();
    _weightController?.dispose();
    _packageTypeController?.close();
    _packageTypeSubscription?.cancel();
    super.dispose();
  }
}
