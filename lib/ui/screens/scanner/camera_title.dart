import 'package:flutter/material.dart';

class CameraTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: MediaQuery.of(context).padding.top + 16,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 44,
        child: Center(
          child: Text(
            'SCAN',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
