import 'package:flutter/material.dart';
import 'package:rescape/data/new_order.dart';
import 'package:rescape/logic/i18n/i18n.dart';

abstract class ResultDialog {
  static Future show(BuildContext context, int statusCode,
          [bool orderConfirmed = false]) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.white70,
          builder: (context) => ResultDialogDisplay(
                statusCode: statusCode,
                orderConfirmed: orderConfirmed,
              ));
}

class ResultDialogDisplay extends StatefulWidget {
  final int statusCode;
  final bool orderConfirmed;

  ResultDialogDisplay({
    @required this.statusCode,
    @required this.orderConfirmed,
  });

  @override
  State<StatefulWidget> createState() {
    return _ResultDialogDisplayState();
  }
}

class _ResultDialogDisplayState extends State<ResultDialogDisplay> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Material(
            elevation: 16,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.statusCode == 200
                        ? I18N.text('Success! Tap \'OK\' to continue')
                        : I18N.text('Error! Please try again later'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(26, 12, 26, 12),
                          child: Text(
                            'OK',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }

  @override
  void dispose() {
    if (widget.statusCode == 200) NewOrder.clear();
    super.dispose();
  }
}
