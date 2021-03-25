import 'package:flutter/material.dart';
import 'package:rescape/data/company_list.dart';
import 'package:rescape/logic/api/companies.dart';
import 'package:rescape/logic/i18n/i18n.dart';
import 'package:rescape/ui/screens/companies/add_company.dart';
import 'package:rescape/ui/shared/confirm_deletion_dialog.dart';

class CompaniesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CompaniesScreenState();
  }
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  Key _key = UniqueKey();

  void _rebuild() => setState(() => _key = UniqueKey());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        key: _key,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12, bottom: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  I18N.text('Locations'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_outlined),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          barrierColor: Colors.white,
                          builder: (context) => AddCompanyDialog(),
                        );
                        _rebuild();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          for (var location in LocationList.instance)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GestureDetector(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: kElevationToShadow[1],
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 64,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            location.companyName +
                                (location.number == '0'
                                    ? ''
                                    : ' ${location.number}'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.red.shade300,
                            ),
                            onPressed: () async {
                              final _deleteCompany =
                                  await CompaniesAPI.remove(location.id);
                              try {
                                await showDialog(
                                  context: context,
                                  builder: (context) => ConfirmDeletionDialog(
                                    future: _deleteCompany,
                                    rebuildParent: _rebuild,
                                  ),
                                );
                              } catch (e) {
                                print('failed');
                                print('$e');
                              }
                              _rebuild();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}
