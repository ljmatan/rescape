import 'package:flutter/material.dart';
import 'add_dialog.dart';

class AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 7,
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                ),
              ],
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.white70,
              builder: (context) => AddDialog(),
            );
          },
        ),
      ),
    );
  }
}
