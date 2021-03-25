import 'package:flutter/material.dart';
import 'package:rescape/data/new_order.dart';
import 'package:rescape/ui/screens/scanner/camera_screen.dart';

class ExitCameraButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      top: MediaQuery.of(context).padding.top + 16,
      child: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).primaryColor,
          ),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                Icons.arrow_left,
                color: Colors.white,
              ),
            ),
          ),
        ),
        onTap: () async {
          if (NewOrder.instance.isNotEmpty)
            await showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.white70,
              builder: (context) => ClearItemsDialog(),
            );
          Navigator.pop(context);
        },
      ),
    );
  }
}
