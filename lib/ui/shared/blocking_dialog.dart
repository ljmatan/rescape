import 'package:flutter/material.dart';

abstract class BlockingDialog {
  static Future show(BuildContext context) async => await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white70,
        builder: (context) => WillPopScope(
          child: Center(child: CircularProgressIndicator()),
          onWillPop: () async => false,
        ),
      );
}
