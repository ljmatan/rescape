import 'package:flutter/material.dart';
import 'package:rescape/ui/screens/main/bloc/main_view_controller.dart';

class CustomNavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;

  CustomNavBarIcon({
    @required this.icon,
    @required this.label,
    @required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MainViewController.stream,
      initialData: 0,
      builder: (context, selected) => Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(
                  icon,
                  color:
                      index == selected.data ? Colors.black87 : Colors.black26,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color:
                      index == selected.data ? Colors.black87 : Colors.black26,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          onTap: () {
            if (selected.data != index) MainViewController.change(index);
          },
        ),
      ),
    );
  }
}
