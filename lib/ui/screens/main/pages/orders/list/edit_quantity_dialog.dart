import 'package:flutter/material.dart';
import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/logic/i18n/i18n.dart';

class EditAmountDialog extends StatefulWidget {
  final OrderItemModel item;
  final Function rebuildParent;

  EditAmountDialog({@required this.item, @required this.rebuildParent});

  @override
  State<StatefulWidget> createState() {
    return _EditAmountDialogState();
  }
}

class _EditAmountDialogState extends State<EditAmountDialog> {
  final _amountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
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
                  widget.item.product.name,
                  style: const TextStyle(fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      autofocus: true,
                      textAlign: TextAlign.center,
                      controller: _amountController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (input) {
                        if (input.isEmpty ||
                            widget.item.product.measureType == Measure.kg &&
                                double.tryParse(input) == null ||
                            widget.item.product.measureType == Measure.qty &&
                                int.tryParse(input) == null)
                          return 'Please check your input';
                        return null;
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        onPrimary: Theme.of(context).primaryColor,
                        primary: Colors.transparent,
                      ),
                      child: Text(I18N.text('CANCEL')),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                      ),
                      child: Text(I18N.text('CONFIRM')),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          widget.item.measure =
                              (widget.item.product.measureType == Measure.kg
                                  ? double.parse(_amountController.text)
                                  : int.parse(_amountController.text));
                          Navigator.pop(context);
                          widget.rebuildParent(() {});
                        }
                      },
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
}
