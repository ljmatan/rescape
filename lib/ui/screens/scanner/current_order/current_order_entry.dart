import 'package:flutter/material.dart';
import 'package:rescape/data/models/order_item_model.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/data/new_order.dart';

class CurrentOrderEntry extends StatefulWidget {
  final OrderItemModel item;

  CurrentOrderEntry({@required this.item});

  @override
  State<StatefulWidget> createState() {
    return _CurrentOrderEntryState();
  }
}

class _CurrentOrderEntryState extends State<CurrentOrderEntry> {
  bool _prepared;

  @override
  void initState() {
    super.initState();
    if (_prepared == null)
      _prepared = NewOrder.instance?.firstWhere(
              (e) => e.product?.barcode == widget.item.product.barcode,
              orElse: () => null) !=
          null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[1],
            borderRadius: BorderRadius.circular(4),
            color: _prepared ? Theme.of(context).primaryColor : Colors.white,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.item.product.name,
                      style: TextStyle(
                        fontWeight: _prepared ? FontWeight.bold : null,
                        color: _prepared ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      widget.item.product.measureType == Measure.kg &&
                              !widget.item.forceMeasure
                          ? '${widget.item.measure}kg'
                          : '×${widget.item.measure.floor()}',
                      style: TextStyle(
                        fontWeight: _prepared ? FontWeight.bold : null,
                        color: _prepared ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
