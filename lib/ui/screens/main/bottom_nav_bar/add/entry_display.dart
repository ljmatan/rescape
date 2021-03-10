import 'package:flutter/material.dart';

class AddEntryDisplay extends StatelessWidget {
  final Widget child;

  AddEntryDisplay({@required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 120,
        child: child,
      ),
    );
  }
}
