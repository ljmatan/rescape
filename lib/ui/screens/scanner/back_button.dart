import 'package:flutter/material.dart';

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
        onTap: () => Navigator.pop(context),
      ),
    );
  }
}
