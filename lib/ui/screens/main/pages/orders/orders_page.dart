import 'package:flutter/material.dart';
import 'package:rescape/ui/screens/main/pages/orders/bloc/view_controller.dart';
import 'package:rescape/ui/screens/main/pages/orders/selection_display.dart';

class OrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrdersPageState();
  }
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    OrdersViewController.init();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: OrdersViewController.stream,
      initialData: SelectionDisplay(),
      builder: (context, selected) => selected.data,
    );
  }

  @override
  void dispose() {
    OrdersViewController.dispose();
    super.dispose();
  }
}
