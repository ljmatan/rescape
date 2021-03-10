import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TorchButton extends StatefulWidget {
  final Function setFlash;

  TorchButton({@required this.setFlash});

  @override
  State<StatefulWidget> createState() {
    return _TorchButtonState();
  }
}

class _TorchButtonState extends State<TorchButton> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 48,
          child: Center(
            child: Text(
              'FLASHLIGHT',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        onTap: () {
          setState(() => _active = !_active);
          widget.setFlash(_active ? FlashMode.torch : FlashMode.off);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
