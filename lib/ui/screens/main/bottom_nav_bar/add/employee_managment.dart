import 'package:flutter/material.dart';

class EmployeeManagment extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget route;

  EmployeeManagment({
    @required this.icon,
    @required this.label,
    @required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Icon(icon, size: 64),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) => route)),
      ),
    );
  }
}
