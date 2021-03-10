import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rescape/data/company_list.dart';
import 'package:rescape/ui/screens/main/pages/orders/selections/new_order/company_selection/company_entry.dart';

class CompanySearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CompanySearchState();
  }
}

class _CompanySearchState extends State<CompanySearch> {
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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 18 + MediaQuery.of(context).padding.top,
            left: 12,
            right: 12,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              controller: _searchTermController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
                hintText: 'Search for companies',
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _searchController.stream,
            initialData: '',
            builder: (context, searchTerm) => ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var company in (searchTerm.data.isEmpty
                    ? LocationList.companies
                    : LocationList.companies
                        .where((e) => e == searchTerm.data)))
                  CompanyEntry(label: company),
                SizedBox(
                  height: 32 +
                      MediaQuery.of(context).viewInsets.bottom -
                      (MediaQuery.of(context).viewInsets.bottom > 72
                          ? 72.0
                          : 0.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchTermController.dispose();
    _searchController.close();
    super.dispose();
  }
}
