import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rescape/data/product_list.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'product_entry.dart';

class ManualEntryDialogDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ManualEntryDialogDialogState();
  }
}

class _ManualEntryDialogDialogState extends State<ManualEntryDialogDialog> {
  final _searchTermController = TextEditingController();
  final _searchController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    _searchTermController
        .addListener(() => _searchController.add(_searchTermController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                autofocus: true,
                controller: _searchTermController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  hintText: I18N.text('Search for products'),
                ),
              ),
            ),
          ),
          StreamBuilder(
            stream: _searchController.stream,
            initialData: '',
            builder: (context, searchTerm) => Column(
              children: [
                for (var product in (searchTerm.data.isEmpty
                    ? ProductList.instance
                    : ProductList.instance.where((e) =>
                        e.name
                            .toLowerCase()
                            .contains(searchTerm.data.toLowerCase()) ||
                        e.barcode == searchTerm.data ||
                        e.id.toString().startsWith(searchTerm.data))))
                  ProductEntry(product: product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchTermController.dispose();
    _searchController.close();
    super.dispose();
  }
}
