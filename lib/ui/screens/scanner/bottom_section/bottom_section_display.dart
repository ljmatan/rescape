import 'package:flutter/material.dart';
import 'package:rescape/data/models/product_model.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/scanner/bloc/last_scanned_controller.dart';
import 'package:rescape/ui/screens/scanner/bottom_section/torch_button.dart';
import 'enter_manually_button.dart';

class BottomSection extends StatelessWidget {
  final Function scanning, setFlash;

  BottomSection({@required this.scanning, @required this.setFlash});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: StreamBuilder(
                stream: LastScannedController.stream,
                builder: (context, orderItem) => orderItem.hasData
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(orderItem.data.product.name),
                          Text(
                            orderItem.data.product.measureType == Measure.kg
                                ? '${orderItem.data.measure}kg'
                                : '×${orderItem.data.measure.floor()}',
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  I18N.text('Scan code\nto add item and weight'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      TorchButton(setFlash: setFlash),
                      EnterManuallyButton(scanning: scanning),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
