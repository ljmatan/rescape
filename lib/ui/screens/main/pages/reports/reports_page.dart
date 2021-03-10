import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportsPageState();
  }
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        top: MediaQuery.of(context).padding.top + 16,
        right: 16,
        bottom: 32,
      ),
      child: Stack(
        children: [],
      ),
    );
  }
}
